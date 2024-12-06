library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;

entity part1 is
  generic(
    size : natural
  );
  port (
    clk         : in std_logic;
    resetn      : in std_logic;
    left_input  : in INTEGER_VECTOR(size - 1 downto 0);
    right_input : in INTEGER_VECTOR(size - 1 downto 0);
    output      : out INTEGER
  );
end entity part1;

architecture rtl of part1 is

  signal abssub_enable      : std_logic;
  signal accumulator_enable : std_logic;

  signal ready_out : std_logic;
  signal left_valid_out : std_logic;
  signal right_valid_out : std_logic;

  signal left_sorted_output  : INTEGER;
  signal right_sorted_output : INTEGER;
  signal abssub_output       : INTEGER;
  signal accumulator_output  : INTEGER;

  component abssub is
  port (
    clk    : in std_logic;
    resetn : in std_logic;
    enable : in std_logic;
    a      : in  INTEGER;
    b      : in  INTEGER;
    c      : out INTEGER
  );
  end component;

  component accumulator is 
  port (
    clk    : in std_logic;
    resetn : in std_logic;
    enable : in std_logic;
    input  : in INTEGER;
    output : out INTEGER
  );
  end component;

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

  output <= accumulator_output;

  mergesort_right: entity work.mergesort
   generic map(
      size => size
  )
   port map(
      clk => clk,
      resetn => resetn,
      input => right_input,
      ext_buf_ready_out => ready_out,
      ext_buf_valid_out => right_valid_out,
      output => right_sorted_output
  );        

  mergesort_left: entity work.mergesort
   generic map(
      size => size
  )
   port map(
      clk => clk,
      resetn => resetn,
      input => left_input,
      ext_buf_ready_out => ready_out,
      ext_buf_valid_out => left_valid_out,
      output => left_sorted_output
  );        
 
  abssub_inst: entity work.abssub 
    port map (
      clk => clk,
      resetn => resetn,
      enable => abssub_enable,
      a => left_sorted_output,
      b => right_sorted_output,
      c => abssub_output
    );

  accumulator_inst: entity work.accumulator
    port map (
      clk => clk,
      resetn => resetn,
      enable => accumulator_enable,
      input => abssub_output,
      output => accumulator_output
    );

 enable_proc: process(clk, resetn)
 begin
  if resetn = '0' then
    abssub_enable <= '0';
    accumulator_enable <= '0';
    ready_out <= '0';
  elsif rising_edge(clk) then
    ready_out <= right_valid_out and left_valid_out;
    accumulator_enable <= abssub_enable;
    abssub_enable <= right_valid_out and left_valid_out;
  end if;
  end process enable_proc;   

end architecture rtl;
