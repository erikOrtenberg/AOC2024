library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity buffer_tb is
end entity buffer_tb;

architecture tb of buffer_tb is
  
  constant period : TIME := 10 ns;

  component buf is
    generic(
    size      : natural
           );
    port (
    clk       : in std_logic;
    resetn    : in std_logic;
    ready_in  : in std_logic;
    ready_out : in std_logic;
    input     : in INTEGER;
    valid_in  : out std_logic;
    valid_out : out std_logic;
    output    : out INTEGER
         );
  end component;

  signal clk       : std_logic := '0';
  signal resetn    : std_logic := '0';
  signal ready_in  : std_logic := '0';
  signal ready_out : std_logic := '0';
  signal input     : INTEGER   :=  0;
  signal valid_in  : std_logic;
  signal valid_out : std_logic;
  signal output    : INTEGER;

  for buf_inst: buf use entity work.buf; 
begin
  
  buf_inst: buf
   generic map(
      size => 4
  )
   port map(
      clk => clk,
      resetn => resetn,
      ready_in => ready_in,
      ready_out => ready_out,
      input => input,
      valid_in => valid_in,
      valid_out => valid_out,
      output => output
  );

  clk_proc : process
  begin
    for i in 0 to 100 loop
      wait for period / 2;
      clk <= not clk; 
      wait for period / 2;
      clk <= not clk; 
    end loop;
    wait;
  end process clk_proc;

  input_proc: process
  begin
    wait for period;
    -- check correct reset vals
    assert output = 0 report "output not reset >:(" severity FAILURE;
    assert valid_in = '0' report "valid_in not reset >:(" severity FAILURE;
    assert valid_out = '0' report "valid_out not reset >:(" severity FAILURE;
    wait for period / 2;
    -- start inserting values;
    resetn <= '1';

    wait for 100*period;
    wait;
  end process input_proc;

  output_proc: process
  begin
  
    wait;
  end process output_proc;
  
end architecture tb ;
