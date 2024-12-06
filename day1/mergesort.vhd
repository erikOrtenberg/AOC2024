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
  input             : in INTEGER_VECTOR(size-1 downto 0);
  ext_buf_ready_out : in std_logic;
  ext_buf_valid_out : out std_logic;
  output            : out INTEGER
  );
end entity mergesort;

architecture recurse of mergesort is
  
  constant newsize      : natural := size / 2;
  signal input_bottom   : INTEGER_VECTOR(newsize-1 downto 0);
  signal input_top      : INTEGER_VECTOR(newsize-1 downto 0);
  signal output_bottom  : INTEGER;
  signal output_top     : INTEGER;

  signal two_output     : INTEGER;
  signal inputs_remain  : INTEGER;

  signal sorted_counter : INTEGER;


  signal top_buf_valid_out    : std_logic; 
  signal top_buf_ready_out    : std_logic; 
  signal bottom_buf_valid_out : std_logic;
  signal bottom_buf_ready_out : std_logic;

  signal internal_top_buf_ready_out    : std_logic; 
  signal internal_bottom_buf_ready_out : std_logic;

  signal buf_ready_in  : std_logic;
  --signal buf_ready_out : std_logic;
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

  top_buf_ready_out <= internal_top_buf_ready_out or (top_buf_valid_out xor bottom_buf_valid_out);
  bottom_buf_ready_out <= internal_bottom_buf_ready_out or (top_buf_valid_out xor bottom_buf_valid_out);

  -- connect inputs
  input_gen: process(input)
  begin
    if size > 1 then
      input_top    <= input(size-1 downto size/2);
      input_bottom <= input(size/2 - 1 downto 0);
    else 
      input_top <= input;
    end if;
  end process input_gen;
  
  with size select 
    output <= two_output   when 2,
              buf_output when others;
  
  topChild: if size/2 > 1 generate 
    top : entity work.mergesort
        generic map (
            size => size/2
        )
        port map ( 
            clk => clk,
            resetn => resetn,
            input => input(size-1 downto size/2),
            ext_buf_valid_out => top_buf_valid_out,
            ext_buf_ready_out => top_buf_ready_out,
            output => output_top
        );
  end generate topChild;
  bottomChild: if size/2 > 1 generate 
    bottom : entity work.mergesort
        generic map (
            size => size/2
        )
        port map ( 
            clk => clk,
            resetn => resetn,
            input => input(size/2 - 1 downto 0),
            ext_buf_valid_out => bottom_buf_valid_out,
            ext_buf_ready_out => bottom_buf_ready_out,
            output => output_bottom
        );
  end generate bottomChild;

  bufGen: if size >= 1 generate
    buf_inst: entity work.buf
      generic map(
        size => size
      )
      port map(
        clk => clk,
        resetn => resetn,
        ready_in => buf_ready_in,
        ready_out => ext_buf_ready_out,
        input => buf_input,
        valid_in => buf_valid_in,
        valid_out => buf_valid_out,
        output => buf_output
      );
  end generate; 

                      ---- CONTROL THE BUFFER CONTROL SIGNALS HERE -----
  -- we need to figure out how to stop sending the same base data in the base case and only 
  -- pretend to be a buffer with a valid input for **one cycle**. After that we can set the
  -- correct control signals to '0' so that parents of the leaf nodes can not consume the 
  -- input more than once.

  sorted_count: process(clk, resetn, ext_buf_ready_out, ext_buf_valid_out)
  begin
    if resetn = '0' then
      sorted_counter <= 0;
    elsif falling_edge(clk) and ext_buf_ready_out = '1' and ext_buf_valid_out = '1' then
      sorted_counter <= sorted_counter + 1;
    end if;
  end process sorted_count;

  sorting_proc: process(clk, resetn, sorted_counter, buf_valid_in, output_top, buf_valid_out, output_bottom, top_buf_valid_out, bottom_buf_valid_out)
  begin
    if resetn = '0' then
      internal_top_buf_ready_out <= '0';
      internal_bottom_buf_ready_out <= '0';
      inputs_remain <= 2;
    -- stop if finished is '1' and 
    -- dont do this unless size is larger than 1
    elsif size <= 2 and sorted_counter < size then
      ext_buf_valid_out <= '1';
      -- BASE CASE 
      if falling_edge(clk) then
        if inputs_remain = 2 then
          if input(0) < input(1) then
            two_output <= input(0);
            inputs_remain <= 1;
          else 
            two_output <= input(1);
            inputs_remain <= 3;
          end if;
        elsif inputs_remain = 1 and ext_buf_ready_out = '1' then
          two_output <= input(1);
          inputs_remain <= 0;
        elsif inputs_remain = 3 and ext_buf_ready_out = '1' then
          two_output <= input(0);
          inputs_remain <= 0;
        end if;
      end if;
    elsif size > 2 and sorted_counter < size then
    -- RECURSING CASE
    ext_buf_valid_out <= buf_valid_out;
    -- update buffer inputs on falling edge
      -- check so that buffer has space
      if buf_valid_in = '1' then 
        -- get correct value based on sorting and availability
        buf_ready_in <= '1';
        if top_buf_valid_out = '1' and bottom_buf_valid_out = '0' then
          --consume from top
          if rising_edge(clk) then
            internal_top_buf_ready_out <= '1';
            internal_bottom_buf_ready_out <= '0';
          end if;
          buf_input <= output_top;
        elsif top_buf_valid_out = '0' and bottom_buf_valid_out = '1' then
          --consume from bottom
          if rising_edge(clk) then
            internal_top_buf_ready_out <= '0';
            internal_bottom_buf_ready_out <= '1';
          end if;
          buf_input <= output_bottom;
        elsif top_buf_valid_out = '1' and bottom_buf_valid_out = '1' then
          --compare and consume from smallest
          if output_top > output_bottom then
            if rising_edge(clk) then
              internal_top_buf_ready_out <= '0';
              internal_bottom_buf_ready_out <= '1';
            end if;
            buf_input <= output_bottom;
          else 
            if rising_edge(clk) then
              internal_top_buf_ready_out <= '1';
              internal_bottom_buf_ready_out <= '0';
            end if;
            buf_input <= output_top;
          end if;
        else
          --don't consume 
          buf_ready_in <= '0';
        end if; 
      end if;
    elsif sorted_counter >= size - 2 then 
      --Finished, stop outputing
      ext_buf_valid_out <= '0';
    end if;
  end process sorting_proc;

end architecture recurse;
