library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench: environment for spi_master
-- - Generates CLK and RESET
-- - Applies data_in to master (Tx)
-- - Models an external SPI slave that drives MISO (Rx test)
-- - Captures MOSI bitstream and checks received data_out
entity tb_spi_master_env is
end entity;

architecture sim of tb_spi_master_env is
  constant DATA_WIDTH : integer := 8;
  constant CLK_PERIOD  : time := 20 ns; -- 50 MHz
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal start : std_logic := '0';
  signal mosi  : std_logic := '0';
  signal miso  : std_logic := '0';
  signal sclk  : std_logic := '0';
  signal ss_n  : std_logic := '1';
  signal data_in  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal busy  : std_logic;
  signal done  : std_logic;

  -- Test vectors
  constant MASTER_TX_WORD   : std_logic_vector(DATA_WIDTH-1 downto 0) := x"A5"; -- what master will send
  constant SLAVE_RESPONSE   : std_logic_vector(DATA_WIDTH-1 downto 0) := x"3C"; -- what slave will send back

  -- Captures
  signal captured_mosi     : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal capture_count     : integer := 0;

begin
  ----------------------------------------------------------------------
  -- Instantiate Unit Under Test: spi_master
  ----------------------------------------------------------------------
  uut: entity work.spi_master
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      CLK_DIV    => 8,  -- half SCLK period in system clocks. Adjust to taste.
      CPOL       => 0,
      CPHA       => 0
    )
    port map (
      clk      => clk,
      rst      => rst,
      start    => start,
      data_in  => data_in,
      mosi     => mosi,
      miso     => miso,
      sclk     => sclk,
      ss_n     => ss_n,
      data_out => data_out,
      busy     => busy,
      done     => done
    );

  ----------------------------------------------------------------------
  -- Clock generator
  ----------------------------------------------------------------------
  clk_proc: process
  begin
    while now < 200 ms loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  ----------------------------------------------------------------------
  -- Reset / Stimulus
  ----------------------------------------------------------------------
  stim_proc: process
  begin
    -- initial reset
    rst <= '1';
    start <= '0';
    wait for 100 ns;
    rst <= '0';
    wait for 100 ns;

    -- first test: single-word transfer
    data_in <= MASTER_TX_WORD;
    wait for 50 ns;

    -- start transfer (pulse start for one clock)
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    -- wait for master to finish transfer
    wait until done = '1';
    wait for 2 * CLK_PERIOD; -- wait a bit for finalization

    -- report captured MOSI and received data
    report "Master transmitted (captured_mosi as integer): "
           & integer'image(to_integer(unsigned(captured_mosi)));
    report "Expected master transmitted (MASTER_TX_WORD as integer): "
           & integer'image(to_integer(unsigned(MASTER_TX_WORD)));
    report "Master received (data_out as integer): "
           & integer'image(to_integer(unsigned(data_out)));
    report "Expected slave response (SLAVE_RESPONSE as integer): "
           & integer'image(to_integer(unsigned(SLAVE_RESPONSE)));

    -- check correctness
    if captured_mosi /= MASTER_TX_WORD then
      report "ERROR: MOSI bitstream does not match expected MASTER_TX_WORD" severity FAILURE;
    else
      report "OK: MOSI bitstream matches expected MASTER_TX_WORD";
    end if;

    if data_out /= SLAVE_RESPONSE then
      report "ERROR: master did not receive expected SLAVE_RESPONSE" severity FAILURE;
    else
      report "OK: master received expected SLAVE_RESPONSE";
    end if;

    wait for 200 ns;
    -- end simulation
    report "Simulation finished" severity NOTE;
    wait;
  end process;

  ----------------------------------------------------------------------
  -- Capture MOSI bitstream (sample on the same edge master uses to sample MISO)
  -- For CPOL=0, CPHA=0 we sample MOSI on rising_edge(sclk).
  ----------------------------------------------------------------------
  capture_mosi_proc: process
  begin
    wait until rst = '0';
    -- idle until slave selects (ss_n active low). We capture while ss_n='0'.
    loop
      wait until ss_n = '0';
      captured_mosi <= (others => '0');
      capture_count <= 0;
      -- capture DATA_WIDTH bits
      while capture_count < DATA_WIDTH loop
        wait until rising_edge(sclk);
        -- shift left and append current MOSI (MSB-first)
        captured_mosi <= captured_mosi(DATA_WIDTH-2 downto 0) & mosi;
        capture_count <= capture_count + 1;
      end loop;
      -- wait until SS release
      wait until ss_n = '1';
    end loop;
  end process;

  ----------------------------------------------------------------------
  -- Simple SPI Slave model (mode 0: CPOL=0, CPHA=0)
  -- Behavior:
  --  - When ss_n goes low, slave presents the MSB of SLAVE_RESPONSE on MISO.
  --  - On each falling edge of SCLK the slave updates MISO to the next bit
  --    so that master's next rising edge sees the correct bit.
  --  - On each rising edge of SCLK the slave samples MOSI into its rx_shift.
  ----------------------------------------------------------------------
  slave_proc: process
    variable slave_tx   : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable slave_rx   : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable bit_index  : integer;
  begin
    miso <= '0';
    wait until rst = '0';
    forever_loop: loop
      wait until ss_n = '0'; -- slave selected
      -- initialize
      slave_tx := SLAVE_RESPONSE;
      slave_rx := (others => '0');
      bit_index := 0;
      -- present MSB before the first rising edge
      miso <= slave_tx(DATA_WIDTH-1);
      -- while selected, respond on falling edge and sample on rising edge
      while ss_n = '0' loop
        -- wait for falling edge to update the next output bit
        wait until falling_edge(sclk);
        bit_index := bit_index + 1;
        if bit_index < DATA_WIDTH then
          miso <= slave_tx(DATA_WIDTH-1 - bit_index);
        end if;
        -- wait for rising edge to sample MOSI
        wait until rising_edge(sclk);
        if bit_index <= DATA_WIDTH then
          -- shift in MOSI (MSB-first)
          slave_rx := slave_rx(DATA_WIDTH-2 downto 0) & mosi;
        end if;
      end loop;
      -- when SS released, report what slave observed
      report "Slave observed MOSI as integer: " & integer'image(to_integer(unsigned(slave_rx)));
      wait for 1 ns; -- small delay
    end loop forever_loop;
  end process;

end architecture;