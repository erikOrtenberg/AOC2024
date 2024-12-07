library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;
use std.textio.all;

entity part2_tb is
end entity part2_tb;
architecture tb of part2_tb is


  constant size   : natural := 1000;

  constant period : TIME := 10 ns;
  signal clk       : std_logic := '1';
  signal resetn    : std_logic := '0';

  signal left_input : INTEGER_VECTOR(size - 1 downto 0);
  signal right_input : INTEGER_VECTOR(size - 1 downto 0);
  signal output    : INTEGER;
  signal ext_buf_valid_out : std_logic;
  signal ext_buf_ready_out : std_logic;

  signal finished : BOOLEAN := FALSE;

  component part2 is
  generic(
  -- must be power of two
  size : natural 
  );
  port ( 
  clk               : in std_logic;
  resetn            : in std_logic;
  left_input        : in INTEGER_VECTOR(size-1 downto 0);
  right_input       : in INTEGER_VECTOR(size-1 downto 0);
  output            : out INTEGER
  );
  end component;

begin
  input_proc: process
    file test_vector                : text open read_mode is "/home/kryddan/repos/AOC2024/day1/input.txt";
    variable row                    : line;
    variable v_data_read            : integer;
    variable v_data_row_counter     : integer := 0;
  begin
    for i in 0 to size - 1 loop
      left_input(i) <= 0;
      right_input(i) <= 0;
    end loop;
    while (not endfile(test_vector)) loop
        readline(test_vector,row);
        -- read left value
        read(row,v_data_read);
        left_input(v_data_row_counter) <= v_data_read;
        -- read right value
        read(row,v_data_read);
        right_input(v_data_row_counter) <= v_data_read;
        v_data_row_counter := v_data_row_counter + 1;
    end loop;
    wait;
  end process;
  
  part2_inst: entity work.part2
   generic map(
      size => size
  )
   port map(
      clk => clk,
      resetn => resetn,
      left_input => left_input,
      right_input => right_input,
      output => output
  );        
  
  clk_proc : process
  begin
    -- THE WAVEFORM WILL NOT CONTINUE IF USING clk <= not clk after period / 2
    while (not finished) loop
      wait for period / 2;
      clk <= not clk; 
    end loop;
    wait;
  end process clk_proc;

  proc_name: process
  begin
    wait for period;
    resetn <= '1';
    ext_buf_ready_out <= '0';
    wait for 5000*period;
    finished <= TRUE;
    wait;
  end process proc_name;
  
end architecture tb;
