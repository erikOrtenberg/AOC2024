library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity buf is
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
end entity buf;


architecture rtl of buf is
  
  type buffer_type is array ((size - 1) downto 0) of INTEGER;

  signal head     : INTEGER range 0 to (size - 1);
  signal tail     : INTEGER range 0 to (size - 1);
  signal nr_elems : INTEGER range 0 to (size);
  signal buff      : buffer_type;

  
  signal internal_valid_in : std_logic;
  signal internal_valid_out : std_logic;
  
begin
  -- permanently bind internal signals to outputs
  valid_out <= internal_valid_out and resetn;
  valid_in <= internal_valid_in and resetn;
  output <= buff(head);

  do_it_all_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      head <= 0;
      tail <= 0;
      nr_elems <= 0;
      for i in 0 to size - 1 loop
        buff(i) <= 0;
      end loop;
    elsif rising_edge(clk) then
      -- capture input in buffer
      if ready_in = '1' and internal_valid_in = '1' then
        buff(tail) <= input;
      end if;
      -- add element to buffer
      if internal_valid_in = '1' and ready_in = '1' then
        nr_elems <= nr_elems + 1;
        if tail + 1 >= size then
          tail <= 0;
        else 
          tail <= tail + 1;
        end if;
      -- consume element from buffer
      elsif internal_valid_out = '1' and ready_out = '1' then
        nr_elems <= nr_elems - 1;
        if head + 1 >= size then
          head <= 0;
        else 
          head <= head + 1;
        end if;
      end if;
    end if;
  end process do_it_all_proc;

  valid_proc: process(head, tail, nr_elems)
  begin
    -- buffer full
    if nr_elems = size then
      internal_valid_in <= '0';
    else
      internal_valid_in <= '1';
    end if;
    -- buffer empty
    if nr_elems = 0 then
      internal_valid_out <= '0';
    else
      internal_valid_out <= '1';
    end if;
  end process valid_proc;

end architecture rtl;
