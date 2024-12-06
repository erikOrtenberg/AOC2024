library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;

entity mergesort_tb is
end entity mergesort_tb;

architecture tb of mergesort_tb is


  constant size   : natural := 256;
  signal received : natural := size;

  constant period : TIME := 10 ns;
  signal clk       : std_logic := '1';
  signal resetn    : std_logic := '0';

  signal input     : INTEGER_VECTOR(size - 1 downto 0);
  signal output    : INTEGER;
  signal ext_buf_valid_out : std_logic;
  signal ext_buf_ready_out : std_logic;

  signal finished : BOOLEAN := FALSE;

  component mergesort is
  generic(
  -- must be power of two
  size : natural 
  );
  port ( 
  clk               : in std_logic;
  resetn            : in std_logic;
  input             : in INTEGER_VECTOR(size-1 downto 0);
  ext_buf_ready_out : in std_logic;
  ext_buf_valid_out : out std_logic;
  output            : out INTEGER
  );
  end component;

begin

  input_bind: process    
    variable seed1, seed2 : POSITIVE; 
    variable rand : real;
    variable range_of_rand : real := 1000.0;
    variable rand_int : INTEGER;
  begin
    for i in 0 to size - 1 loop
      uniform(seed1, seed2, rand);              -- generate random number
      rand_int := integer(rand*range_of_rand);  -- rescale to 0..1000, convert integer part 
      assert false report INTEGER'image(rand_int) severity note;
      input(i) <= rand_int;
    end loop;
  wait;
  end process input_bind;
  
  mergesort_inst: entity work.mergesort
   generic map(
      size => size
  )
   port map(
      clk => clk,
      resetn => resetn,
      input => input,
      ext_buf_ready_out => ext_buf_ready_out,
      ext_buf_valid_out => ext_buf_valid_out,
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
    wait for 1000*period;
    finished <= TRUE;
    wait;
  end process proc_name;
  
end architecture tb;
