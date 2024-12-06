library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accumulator is
  port (
    clk      : in std_logic;
    resetn   : in std_logic;
    enable   : in std_logic;
    input    : in INTEGER;
    output   : out INTEGER
  );
end entity accumulator;

architecture rtl of accumulator is
  signal acc : INTEGER;
begin
  output <= acc;
  acc_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      acc <= 0;
    elsif rising_edge(clk) and enable = '1' then
      acc <= acc + input;
    end if;
  end process acc_proc;
end architecture rtl;
