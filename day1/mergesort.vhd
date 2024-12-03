library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--- MERGE SORT MODULE
--- This module will sort the input array vector of 
--- integers in an acsending order 

entity mergesort is
  generic(
  -- must be power of two
  size : natural 
  );
  port ( 
  clk               : in std_logic;
  resetn            : in std_logic;
  input             : in INTEGER_VECTOR(size downto 0);
  ext_buf_ready_out : in std_logic;
  ext_buf_valid_out : out std_logic;
  output            : out INTEGER
  );
end entity mergesort;

architecture recurse of mergesort is
  
  constant newsize      : natural := size / 2;
  signal input_bottom   : INTEGER_VECTOR(newsize downto 0);
  signal input_top      : INTEGER_VECTOR(newsize downto 0);
  signal output_bottom  : INTEGER;
  signal output_top     : INTEGER;

  signal top_buf_valid_out    : std_logic; 
  signal top_buf_ready_out    : std_logic; 
  signal bottom_buf_valid_out : std_logic;
  signal bottom_buf_ready_out : std_logic;

  signal buf_ready_in  : std_logic;
  signal buf_ready_out : std_logic;
  signal buf_input     : INTEGER;
  signal buf_valid_in  : std_logic;
  signal buf_valid_out : std_logic;
  signal buf_output    : INTEGER;

  signal finished : std_logic;

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
  

begin

                      ---- CONTROL THE BUFFER CONTROL SIGNALS HERE -----
  -- we need to figure out how to stop sending the same base data in the base case and only 
  -- pretend to be a buffer with a valid input for **one cycle**. After that we can set the
  -- correct control signals to '0' so that parents of the leaf nodes can not consume the 
  -- input more than once.
  
  with size select 
    output <= input(0)   when 1,
              input(0)   when 0,
              buf_output when others;
  
  topChild: if size/2 > 1 generate 
    top : entity work.mergesort
        generic map (
            size => size/2
        )
        port map ( 
            clk => clk,
            resetn => resetn,
            input => input_top,
            ext_buf_valid_out => top_buf_valid_out,
            ext_buf_ready_out => top_buf_ready_out,
            output => output_top
        );
  end generate topChild;
  bottomChild: if size/2 > 1 generate 
    top : entity work.mergesort
        generic map (
            size => size/2
        )
        port map ( 
            clk => clk,
            resetn => resetn,
            input => input_bottom,
            ext_buf_valid_out => bottom_buf_valid_out,
            ext_buf_ready_out => bottom_buf_ready_out,
            output => output_bottom
        );
  end generate bottomChild;

  bufGen: if size > 1 generate
    buf_inst: entity work.buf
      generic map(
        size => size
      )
      port map(
        clk => clk,
        resetn => resetn,
        ready_in => buf_ready_in,
        ready_out => buf_ready_out,
        input => buf_input,
        valid_in => buf_valid_in,
        valid_out => buf_valid_out,
        output => buf_output
      );
  end generate; 


  sorting_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      finished <= '0';
    -- stop if finished is '1' and 
    -- dont do this unless size is larger than 1
    elsif size > 1 and finished = '0' then
      -- update buffer inputs on falling edge
      if falling_edge(clk) then
        -- check so that buffer has space
        if buf_valid_in = '1' then 
          -- get correct value based on sorting and availability
          if top_buf_valid_out = '1' and bottom_buf_valid_out = '0' then
            --consume from top
            top_buf_ready_out <= '1';
            buf_input <= output_top;
            buf_ready_in <= '1';
          elsif top_buf_valid_out = '0' and bottom_buf_valid_out = '1' then
            --consume from bottom
            bottom_buf_ready_out <= '1';
            buf_input <= output_bottom;
            buf_ready_in <= '1';
          elsif bottom_buf_valid_out = '1' and top_buf_valid_out = '1' then
            --compare and consume from smallest
            buf_ready_in <= '1';
            if output_top > output_bottom then
              bottom_buf_ready_out <= '1';
              buf_input <= output_bottom;
            else 
              top_buf_ready_out <= '1';
              buf_input <= output_top;
            end if;
          else
            --don't consume 
            buf_ready_in <= '0';
            finished <= '1';
          end if; 
        end if;
      end if;
    end if;
  end process sorting_proc;

end architecture recurse;
