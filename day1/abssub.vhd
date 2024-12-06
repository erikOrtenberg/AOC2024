library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity abssub is
  port (
    clk    : in std_logic;
    resetn : in std_logic;
    enable : in std_logic;
    a      : in  INTEGER;
    b      : in  INTEGER;
    c      : out INTEGER
  );
end entity abssub;

architecture rtl of abssub is
  signal c_r : INTEGER;
begin
  c <= c_r;
  main: process(clk, resetn)
  begin
    if resetn = '0' then
      c_r <= 0;
    elsif rising_edge(clk) then
      c_r <= "abs"(a - b);
    end if;
  end process main; 
end architecture rtl;
