library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity systolic_array is
  port (
    clk           : in std_logic;
    resetn        : in std_logic;
    stream_top    : in INTEGER;
    stream_left   : in INTEGER;
    stream_bottom : out INTEGER;
    stream_right  : out INTEGER;
    output        : out INTEGER
  );
end entity systolic_array;

architecture rtl of systolic_array is
  
  signal count        : INTEGER;
  signal top_bot_r    : INTEGER;
  signal left_right_r : INTEGER;

begin
  stream_bottom <= top_bot_r;
  stream_right <= left_right_r;
  output <= count;

  -- Update internal registers
  stream_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      top_bot_r <= 0;
      left_right_r <= 0;
    elsif rising_edge(clk) then
      top_bot_r <= stream_top;
      left_right_r <= stream_left;
    end if;
  end process stream_proc;

  -- Functional unit inside SA unit
  count_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      count <= 0;
    elsif rising_edge(clk) then
      if stream_left = stream_top then
        count <= count + 1;
      end if;
    end if;
  end process count_proc;
  
end architecture rtl;
