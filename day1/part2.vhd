library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity part2 is
  generic (
    size : natural
  );
  port (
    clk         : in std_logic;
    resetn      : in std_logic;
    left_input  : in INTEGER_VECTOR(size - 1 downto 0);
    right_input : in INTEGER_VECTOR(size - 1 downto 0);
    output      : out INTEGER
  );
end entity part2;

architecture rtl of part2 is
  signal right_head : INTEGER range 0 to (size - 1);
  signal mult_head  : INTEGER range 0 to (size - 1);

  signal start_acc  : std_logic;
  signal acc_enable : std_logic;
  signal acc_inp    : INTEGER;
  signal acc_output : INTEGER;

  signal top_arr    : INTEGER_VECTOR(size - 1 downto 0);
  signal bottom_arr : INTEGER_VECTOR(size - 1 downto 0);
  signal output_arr : INTEGER_VECTOR( size - 1 downto 0);
  signal mult_arr   : INTEGER_VECTOR(size - 1 downto 0);

  component systolic_array is
    port (
      clk           : in std_logic;
      resetn        : in std_logic;
      stream_top    : in INTEGER;
      stream_left   : in INTEGER;
      stream_bottom : out INTEGER;
      stream_right  : out INTEGER;
      output        : out INTEGER
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
begin
  -- Bind output
  output <= acc_output;
  -- Simulate a buffer
  top_arr(0) <= right_input(right_head);
  -- Bind the intermediate systolic array signals 
  arr_bind: for i in 1 to (size - 1) generate
    top_arr(i) <= bottom_arr(i-1);
  end generate arr_bind;

  -- Generate systolic array. Also bind multiplication calculation
  sys: for i in 0 to (size - 1) generate
    sys_arr_inst: entity work.systolic_array
      port map (
        clk => clk,
        resetn => resetn,
        stream_top => top_arr(i),
        stream_left => left_input(i),
        stream_bottom => bottom_arr(i),
        output => output_arr(i)
      );
    mult_arr(i) <= output_arr(i) * left_input(i);
  end generate sys;

  -- Generate accumulator
  acc_inp <= mult_arr(mult_head);
  acc_inst: entity work.accumulator
    port map (
      clk => clk,
      resetn => resetn,
      enable => acc_enable,
      input => acc_inp,
      output => acc_output
    );

  -- Simulate buffer 
  shift_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      start_acc <= '0';
      right_head <= 0;
    elsif rising_edge(clk) then
      if right_head = size - 1 then
        start_acc <= '1';
      else
        right_head <= right_head + 1;
      end if;
    end if;
  end process shift_proc;

  -- Control the accumulator (wait until results are available)
  acc_proc: process(clk, resetn)
  begin
    if resetn = '0' then
      mult_head <= 0;
      acc_enable <= '0';
    elsif rising_edge(clk) and start_acc = '1' then
      if mult_head = size - 1 then 
        acc_enable <= '0';
      else 
        acc_enable <= '1';
        mult_head <= mult_head + 1;
      end if;
    end if;
  end process acc_proc;
end architecture rtl;
