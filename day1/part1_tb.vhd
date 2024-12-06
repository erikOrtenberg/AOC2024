library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;
use std.textio.all;

entity part1_tb is
end entity part1_tb;
architecture tb of part1_tb is


  constant size   : natural := 1024;
  signal received : natural := size;

  constant period : TIME := 10 ns;
  signal clk       : std_logic := '1';
  signal resetn    : std_logic := '0';

  signal left_input : INTEGER_VECTOR(size - 1 downto 0);
  signal right_input : INTEGER_VECTOR(size - 1 downto 0);
  signal output    : INTEGER;
  signal ext_buf_valid_out : std_logic;
  signal ext_buf_ready_out : std_logic;

  signal finished : BOOLEAN := FALSE;

  component part1 is
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

  --input_bind: process    
  --  variable seed1, seed2 : POSITIVE; 
  --  variable rand : real;
  --  variable range_of_rand : real := 1000.0;
  --  variable rand_int : INTEGER;
  --begin
  --  for i in 0 to size - 1 loop
  --    uniform(seed1, seed2, rand);              -- generate random number
  --    rand_int := integer(rand*range_of_rand);  -- rescale to 0..1000, convert integer part 
  --    left_input(i) <= rand_int;
  --    uniform(seed1, seed2, rand);              -- generate random number
  --    rand_int := integer(rand*range_of_rand);  -- rescale to 0..1000, convert integer part 
  --    right_input(i) <= rand_int;
  --  end loop;
  --wait;
  --end process input_bind;
  
  part1_inst: entity work.part1
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
