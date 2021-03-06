-- File: trigger_digital.vhd
-- Generated by MyHDL 0.7
-- Date: Thu May  9 20:55:49 2013


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.pck_myhdl_07.all;

entity trigger_digital is
    port (
        clk: in std_logic;
        reset: in std_logic;
        dataIn: in unsigned(15 downto 0);
        pattern: in unsigned(63 downto 0);
        samples: in unsigned(1 downto 0);
        trigger: out std_logic;
        inputEnable: in std_logic;
        alwaysEn: in std_logic
    );
end entity trigger_digital;
-- simple logic analyzer trigger.
-- clk - clock
-- reset - asynchronous reset
-- dataIn - input data
-- pattern - data pattern
-- samples - number of samples to compare (1 .. 4)
-- inputEnable - clock of data coming from decimator, on which frequency data is checked in trigger
-- alwaysEn - use clk instead of inputEnable (used when decmiation is set to 1:1)

architecture MyHDL of trigger_digital is

signal clkEn: std_logic;
type t_array_previousValues is array(0 to 4-1) of unsigned(15 downto 0);
signal previousValues: t_array_previousValues;

begin



-- This process defines triggering according to selected sample number and pattern
TRIGGER_DIGITAL_TRIGGERING: process (clk, reset) is
begin
    if (reset = '1') then
        trigger <= '0';
        previousValues(0) <= "0000000000000000";
        previousValues(1) <= "0000000000000000";
        previousValues(2) <= "0000000000000000";
    elsif rising_edge(clk) then
        if (not to_boolean(inputEnable)) then
            clkEn <= '1';
        end if;
        if (to_boolean(inputEnable) and (to_boolean(clkEn) or to_boolean(alwaysEn))) then
            clkEn <= '0';
            previousValues(0) <= dataIn;
            previousValues(1) <= previousValues(0);
            previousValues(2) <= previousValues(1);
            case samples is
                when "00" =>
                    if (pattern(16-1 downto 0) = dataIn) then
                        trigger <= '1';
                    else
                        trigger <= '0';
                    end if;
                when "01" =>
                    if ((pattern(16-1 downto 0) = dataIn) and (pattern(32-1 downto 16) = previousValues(0))) then
                        trigger <= '1';
                    else
                        trigger <= '0';
                    end if;
                when "10" =>
                    if ((pattern(16-1 downto 0) = dataIn) and (pattern(32-1 downto 16) = previousValues(0)) and (pattern(48-1 downto 32) = previousValues(1))) then
                        trigger <= '1';
                    else
                        trigger <= '0';
                    end if;
                when others => -- "11"
                    if ((pattern(16-1 downto 0) = dataIn) and (pattern(32-1 downto 16) = previousValues(0)) and (pattern(48-1 downto 32) = previousValues(1)) and (pattern(64-1 downto 48) = previousValues(2))) then
                        trigger <= '1';
                    else
                        trigger <= '0';
                    end if;
            end case;
        end if;
    end if;
end process TRIGGER_DIGITAL_TRIGGERING;

end architecture MyHDL;
