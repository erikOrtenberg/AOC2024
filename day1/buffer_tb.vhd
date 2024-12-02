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

  signal clk       : std_logic := '1';
  signal resetn    : std_logic := '0';
  signal ready_in  : std_logic := '0';
  signal ready_out : std_logic := '0';
  signal input     : INTEGER   :=  0;
  signal valid_in  : std_logic;
  signal valid_out : std_logic;
  signal output    : INTEGER;

  for buf_inst: buf use entity work.buf; 

  signal finished : BOOLEAN := FALSE;
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
    -- THE WAVEFORM WILL NOT CONTINUE IF USING clk <= not clk after period / 2
    while (not finished) loop
      wait for period / 2;
      clk <= not clk; 
    end loop;
    wait;
  end process clk_proc;

  invariants: process
  begin
    --skip init
    wait for 5*period/2;
    while (not finished) loop
      wait for period / 8;
      assert not ((not valid_in) and (not valid_out)) report "valid_in and valid_out can't both be 0" severity FAILURE; 
    end loop;
    wait;
  end process invariants;

  input_proc: process
  begin
  
    wait for period;
    -- check correct reset vals
    assert output = 0 report "output not reset >:(" severity FAILURE;
    assert valid_in = '0' report "valid_in not reset >:(" severity FAILURE;
    assert valid_out = '0' report "valid_out not reset >:(" severity FAILURE;
    wait for period;
    -- start inserting values;
    resetn <= '1';

  -- loop to make sure the cyclic bufffer still works after many cycles
    wait for period/2;
  for i in 1 to 10 loop
    -- buffer contains 0 elements, inserting one
    assert valid_in = '1' report "valid_in is 0 should be able to receive >:(" severity FAILURE;
    assert valid_out = '0' report "valid_out is 1, should be empty >:(" severity FAILURE;
    input <= 1*i;
    ready_in <= '1';
    
    wait for period;
    -- buffer contains 1 elements, inserting one
    assert valid_in = '1' report "valid_in is 0 should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    input <= 2*i;
    wait for period;
    -- buffer contains 2 elements, inserting one
    assert valid_in = '1' report "valid_in is 0 should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    input <= 3*i;
    wait for period;
    -- buffer contains 3 elements, inserting one
    assert valid_in = '1' report "valid_in is 0 should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    input <= 4*i;
    wait for period;
    -- buffer contains 4 elements, should be full
    assert valid_in = '0' report "valid_in is 1, should be full >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    --Moving on... Removing elements
    ready_in <= '0';
    ready_out <= '1';
    wait for period * 1 / 4;

    assert output = 1*i report "first inserted element was not outputed ;_;" severity FAILURE;

    wait for period * 3 / 4;
    -- buffer contains 3 elements,
    assert valid_in = '1' report "valid_in is 0, should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    wait for period * 1 / 4;

    assert output = 2*i report "second inserted element was not outputed ;_;" severity FAILURE;

    wait for period * 3 / 4;
    -- buffer contains 2 elements,
    assert valid_in = '1' report "valid_in is 0, should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    wait for period * 1 / 4;

    assert output = 3*i report "third inserted element was not outputed ;_;" severity FAILURE;

    wait for period * 3 / 4;
    -- buffer contains 1 elements,
    assert valid_in = '1' report "valid_in is 0, should be able to receive >:(" severity FAILURE;
    assert valid_out = '1' report "valid_out is 0, should be able to send >:(" severity FAILURE;
    
    wait for period * 1 / 4;

    assert output = 4*i report "fourth inserted element was not outputed ;_;" severity FAILURE;

    wait for period * 3 / 4;
    -- buffer contains 0 elements,
    assert valid_in = '1' report "valid_in is 0, should be able to receive >:(" severity FAILURE;
    assert valid_out = '0' report "valid_out is 1, should empty >:(" severity FAILURE;
    
    wait for period;
    -- make sure output goes back to front of queue
    assert output = 1*i report "first inserted element is not steady at output ;_;" severity FAILURE;
    ready_out <= '0';
    wait for period;
    wait for period;
    
  end loop;

    
    finished <= TRUE;
    wait;
  end process input_proc;

  
end architecture tb ;
