-- #######################################################
-- #     < STORM Core Processor by Stephan Nolting >     #
-- # *************************************************** #
-- #        STORM Core / STORM Demo SoC Testbench        #
-- # *************************************************** #
-- # Last modified: 04.03.2012                           #
-- #######################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.STORM_core_package.all;

entity TOP_STORM_core is
port (
		MAIN_RST        : in STD_LOGIC;
		MAIN_CLK        : in STD_LOGIC;
		START           : in STD_LOGIC;
        STOP            : in STD_LOGIC;
        STEP            : in STD_LOGIC;
--        up              : in std_logic;
--        down            : in std_logic;
        lcd_e           : out STD_LOGIC;
        lcd_rs          : out std_logic;
        lcd_db          : out std_logic_vector(7 downto 4)
	);
end TOP_STORM_core;

architecture Structure of TOP_STORM_core is

	-- Address Map --------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant INT_MEM_BASE_C  : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
		constant INT_MEM_SIZE_C  : natural := 1*1024; -- bytes
		constant GP_IO_BASE_C    : STD_LOGIC_VECTOR(31 downto 0) := x"FFFFE020";
		constant GP_IO_SIZE_C    : natural := 2*4; -- two 4-byte registers = 8 bytes


	-- Architecture Constants ---------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		constant BOOT_VECTOR_C        : STD_LOGIC_VECTOR(31 downto 0) := INT_MEM_BASE_C;
		constant IO_BEGIN_C           : STD_LOGIC_VECTOR(31 downto 0) :=  x"FFFFE020"; -- first addr of IO area
		constant IO_END_C             : STD_LOGIC_VECTOR(31 downto 0) :=  x"FFFFE024"; -- last addr of IO area
		constant I_CACHE_PAGES_C      : natural := 4;  -- number of pages in I cache
		constant I_CACHE_PAGE_SIZE_C  : natural := 16; -- page size in I cache
		constant D_CACHE_PAGES_C      : natural := 4;  -- number of pages in D cache
		constant D_CACHE_PAGE_SIZE_C  : natural := 4;  -- page size in D cache
		
    -- Wishbone Core Bus --
    signal CORE_WB_ADR_O   : STD_LOGIC_VECTOR(31 downto 0); -- address
    signal CORE_WB_CTI_O   : STD_LOGIC_VECTOR(02 downto 0); -- cycle type
    signal CORE_WB_TGC_O   : STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
    signal CORE_WB_SEL_O   : STD_LOGIC_VECTOR(03 downto 0); -- byte select
    signal CORE_WB_WE_O    : STD_LOGIC;                     -- write enable
    signal CORE_WB_DATA_O  : STD_LOGIC_VECTOR(31 downto 0); -- data out
    signal CORE_WB_DATA_I  : STD_LOGIC_VECTOR(31 downto 0); -- data in
    signal CORE_WB_STB_O   : STD_LOGIC;                     -- valid transfer
    signal CORE_WB_CYC_O   : STD_LOGIC;                     -- valid cycle
    signal CORE_WB_ACK_I   : STD_LOGIC;                     -- acknowledge
    signal CORE_WB_ERR_I   : STD_LOGIC;                     -- abnormal termination
    signal CORE_WB_HALT_I  : STD_LOGIC;                     -- halt request


	-- Component interface ------------------------------------------------------------
	-- -----------------------------------------------------------------------------------

		-- Internal Working Memory --
		signal INT_MEM_DATA_O    : STD_LOGIC_VECTOR(31 downto 0);
		signal INT_MEM_STB_I     : STD_LOGIC;
		signal INT_MEM_ACK_O     : STD_LOGIC;
		signal INT_MEM_ERR_O     : STD_LOGIC;
		signal INT_MEM_HALT_O    : STD_LOGIC;

		-- General Purpose IO Controller --
		signal GP_IO_CTRL_DATA_O : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO_CTRL_STB_I  : STD_LOGIC;
		signal GP_IO_CTRL_ACK_O  : STD_LOGIC;
		signal GP_IO_CTRL_ERR_O  : STD_LOGIC;
		signal GP_IO_CTRL_HALT_O : STD_LOGIC;
		signal GP_IO_OUT_PORT    : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO_IN_PORT     : STD_LOGIC_VECTOR(31 downto 0);
		signal GP_IO_O_S         : STD_LOGIC_VECTOR(31 downto 0);
		
		
		
--------------------------push button--------------------------------------
        signal s_start           : STD_LOGIC;
        signal s_stop            : STD_LOGIC;
        signal s_step            : STD_LOGIC;
--        signal s_up              : STD_LOGIC;
--        signal s_down            : STD_LOGIC;
        signal db1               : STD_LOGIC;
        signal db2               : STD_LOGIC;
        signal db3               : STD_LOGIC;
--        signal db4               : STD_LOGIC;
--        signal db5               : STD_LOGIC;
--        signal db6               : STD_LOGIC;
--        signal db7               : STD_LOGIC;
--        signal db8               : STD_LOGIC;
--        signal db9               : STD_LOGIC;
        signal s_step_db         : STD_LOGIC;
        signal s_step_db_last    : STD_LOGIC;
--        signal s_up_db           : STD_LOGIC;
--        signal s_up_db_last      : STD_LOGIC;
--        signal s_down_db         : STD_LOGIC;
--        signal s_down_db_last    : STD_LOGIC;
        signal s_exe             : STD_LOGIC;
        signal Clk               : STD_LOGIC := '0';
--        signal s_Rst_n           : STD_LOGIC;
        signal IO_O_SYNC         : STD_LOGIC_VECTOR(31 downto 0);
        
        signal keep_entry        : std_logic := '0';
        signal keep_entry_1      : std_logic := '0';
        


	-- Logarithm duales ---------------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		function log2(temp : natural) return natural is
		begin
			for i in 0 to integer'high loop
				if (2**i >= temp) then
					return i;
				end if;
			end loop;
			return 0;
		end function log2;


	-- STORM Core Top Entity ----------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component STORM_TOP
			generic (
						I_CACHE_PAGES     : natural := 4;  -- number of pages in I cache
						I_CACHE_PAGE_SIZE : natural := 32; -- page size in I cache
						D_CACHE_PAGES     : natural := 8;  -- number of pages in D cache
						D_CACHE_PAGE_SIZE : natural := 4;  -- page size in D cache
						BOOT_VECTOR       : STD_LOGIC_VECTOR(31 downto 0); -- boot address
						IO_UC_BEGIN       : STD_LOGIC_VECTOR(31 downto 0); -- begin of uncachable IO area
						IO_UC_END         : STD_LOGIC_VECTOR(31 downto 0)  -- end of uncachable IO area
				);
			port (
						-- Global Control --
						CORE_CLK_I    : in  STD_LOGIC; -- core clock input
						RST_I         : in  STD_LOGIC; -- global reset input
						IO_PORT_O     : out STD_LOGIC_VECTOR(15 downto 0); -- direct output
						IO_PORT_I     : in  STD_LOGIC_VECTOR(15 downto 0); -- direct input

						-- Wishbone Bus --
						WB_ADR_O      : out STD_LOGIC_VECTOR(31 downto 0); -- address
						WB_CTI_O      : out STD_LOGIC_VECTOR(02 downto 0); -- cycle type
						WB_TGC_O      : out STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_SEL_O      : out STD_LOGIC_VECTOR(03 downto 0); -- byte select
						WB_WE_O       : out STD_LOGIC;                     -- write enable
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- data out
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- data in
						WB_STB_O      : out STD_LOGIC;                     -- valid transfer
						WB_CYC_O      : out STD_LOGIC;                     -- valid cycle
						WB_ACK_I      : in  STD_LOGIC;                     -- acknowledge
						WB_ERR_I      : in  STD_LOGIC;                     -- abnormal cycle termination
						WB_HALT_I     : in  STD_LOGIC;                     -- halt request

						-- Interrupt Request Lines --
						IRQ_I         : in  STD_LOGIC; -- interrupt request
						FIQ_I         : in  STD_LOGIC  -- fast interrupt request
				);
		end component;


	-- Internal Working Memory --------------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component MEMORY
			generic	(
						MEM_SIZE      : natural := 256;  -- memory cells
						LOG2_MEM_SIZE : natural := 8;    -- log2(memory cells)
						OUTPUT_GATE   : boolean := FALSE -- output and-gate, might be necessary for some bus systems
					);
			port	(
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				--		WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC_VECTOR(LOG2_MEM_SIZE-1 downto 0); -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
				--		WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC  -- abnormal cycle termination
					);
		end component;


	-- General Purpose IO Controller --------------------------------------------------
	-- -----------------------------------------------------------------------------------
		component GP_IO_CTRL
			port (
						-- Wishbone Bus --
						WB_CLK_I      : in  STD_LOGIC; -- memory master clock
						WB_RST_I      : in  STD_LOGIC; -- high active sync reset
						WB_CTI_I      : in  STD_LOGIC_VECTOR(02 downto 0); -- cycle indentifier
				--		WB_TGC_I      : in  STD_LOGIC_VECTOR(06 downto 0); -- cycle tag
						WB_ADR_I      : in  STD_LOGIC;                     -- adr in
						WB_DATA_I     : in  STD_LOGIC_VECTOR(31 downto 0); -- write data
						WB_DATA_O     : out STD_LOGIC_VECTOR(31 downto 0); -- read data
						WB_SEL_I      : in  STD_LOGIC_VECTOR(03 downto 0); -- data quantity
						WB_WE_I       : in  STD_LOGIC; -- write enable
						WB_STB_I      : in  STD_LOGIC; -- valid cycle
						WB_ACK_O      : out STD_LOGIC; -- acknowledge
						WB_HALT_O     : out STD_LOGIC; -- throttle master
						WB_ERR_O      : out STD_LOGIC; -- abnormal termination

						-- IO Port --
						GP_IO_O       : out STD_LOGIC_VECTOR(31 downto 00);
						GP_IO_I       : in  STD_LOGIC_VECTOR(31 downto 00);

						-- Input Change INT --
						IO_IRQ_O      : out STD_LOGIC;
--						up            : in std_logic;
--						down          : in std_logic;
						lcd_e  : out std_logic;
                        lcd_rs : out std_logic;
                        lcd_db : out std_logic_vector(7 downto 4)

				 );
		end component;
		
--		component lcd16x2_ctrl_demo is
--          port (
--            clk    : in  std_logic;
--            rst    : in std_logic;
--            lcd_e  : out std_logic;
--            lcd_rs : out std_logic;
--            lcd_db : out std_logic_vector(7 downto 4));  
--        end component;

begin

	-- STORM CORE PROCESSOR --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		STORM_TOP_INST: STORM_TOP
			generic map (
								I_CACHE_PAGES     => I_CACHE_PAGES_C,     -- number of pages in I cache
								I_CACHE_PAGE_SIZE => I_CACHE_PAGE_SIZE_C, -- page size in I cache
								D_CACHE_PAGES     => D_CACHE_PAGES_C,     -- number of pages in D cache
								D_CACHE_PAGE_SIZE => D_CACHE_PAGE_SIZE_C, -- page size in D cache
								BOOT_VECTOR       => BOOT_VECTOR_C,       -- startup boot address
								IO_UC_BEGIN       => IO_BEGIN_C,          -- begin of uncachable IO area
								IO_UC_END         => IO_END_C             -- end of uncachable IO area
						)
			port map (
								-- Global Control --
								CORE_CLK_I        => Clk,        -- core clock input
								RST_I             => MAIN_RST,        -- global reset input
								IO_PORT_O         => open,            -- direct output
								IO_PORT_I         => x"0000",         -- direct input

								-- Wishbone Bus --
								WB_ADR_O          => CORE_WB_ADR_O,   -- address
								WB_CTI_O          => CORE_WB_CTI_O,   -- cycle type
								WB_TGC_O          => CORE_WB_TGC_O,   -- cycle tag
								WB_SEL_O          => CORE_WB_SEL_O,   -- byte select
								WB_WE_O           => CORE_WB_WE_O,    -- write enable
								WB_DATA_O         => CORE_WB_DATA_O,  -- data out
								WB_DATA_I         => CORE_WB_DATA_I,  -- data in
								WB_STB_O          => CORE_WB_STB_O,   -- valid transfer
								WB_CYC_O          => CORE_WB_CYC_O,   -- valid cycle
								WB_ACK_I          => CORE_WB_ACK_I,   -- acknowledge
								WB_ERR_I          => CORE_WB_ERR_I,   -- abnormal cycle termination
								WB_HALT_I         => CORE_WB_HALT_I,  -- halt request

								-- Interrupt Request Lines --
								IRQ_I             => '0',       -- interrupt request
								FIQ_I             => '0'       -- fast interrupt request
					);



-- #################################################################################################################################
-- ###  WISHBONE FABRIC                                                                                                          ###
-- #################################################################################################################################

	-- Valid Transfer Signal -------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INT_MEM_STB_I    <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= INT_MEM_BASE_C) and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(INT_MEM_BASE_C) + INT_MEM_SIZE_C))) else '0';
		GP_IO_CTRL_STB_I <= CORE_WB_STB_O when ((CORE_WB_ADR_O >= GP_IO_BASE_C)   and (CORE_WB_ADR_O < Std_logic_Vector(unsigned(GP_IO_BASE_C)   + GP_IO_SIZE_C)))   else '0';

	-- Read-Back Data Selector -----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_DATA_I <=
			INT_MEM_DATA_O    when (INT_MEM_STB_I    = '1') else
			GP_IO_CTRL_DATA_O when (GP_IO_CTRL_STB_I = '1') else
			x"00000000";



--		CORE_WB_DATA_I <= INT_MEM_DATA_O     or
--		                  GP_IO_CTRL_DATA_O  or
--		                  x"00000000";


	-- Acknowledge Terminal --------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ACK_I <=  INT_MEM_ACK_O      or
		                  GP_IO_CTRL_ACK_O   or
		                  '0';


	-- Halt Terminal ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_HALT_I <= INT_MEM_HALT_O     or
		                  GP_IO_CTRL_HALT_O  or
		                  '0';


	-- Halt Terminal ---------------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		CORE_WB_ERR_I <=  INT_MEM_ERR_O      or
		                  GP_IO_CTRL_ERR_O   or
		                  '0';



-- #################################################################################################################################
-- ###  SYSTEM COMPONENTS                                                                                                        ###
-- #################################################################################################################################

	-- Internal Working Memory -----------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		INTERNAL_MEMORY: MEMORY
			generic map	(
						MEM_SIZE      => INT_MEM_SIZE_C/4, -- memory size in 32-bit cells
						LOG2_MEM_SIZE => log2(INT_MEM_SIZE_C/4), -- log2 memory size in 32-bit cells
						OUTPUT_GATE   => FALSE -- not necessary here
						)
			port map(
						WB_CLK_I      => Clk,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
				--		WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(log2(INT_MEM_SIZE_C/4)+1 downto 2), -- word boundary access
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => INT_MEM_DATA_O,
				--		WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => INT_MEM_STB_I,
						WB_ACK_O      => INT_MEM_ACK_O,
						WB_HALT_O     => INT_MEM_HALT_O,
						WB_ERR_O      => INT_MEM_ERR_O
					);



	-- General Purpose IO ----------------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------------
		IO_CONTROLLER: GP_IO_CTRL
			port map (
						-- Wishbone Bus --
						WB_CLK_I      => Clk,
						WB_RST_I      => MAIN_RST,
						WB_CTI_I      => CORE_WB_CTI_O,
				--  	WB_TGC_I      => CORE_WB_TGC_O,
						WB_ADR_I      => CORE_WB_ADR_O(2),
						WB_DATA_I     => CORE_WB_DATA_O,
						WB_DATA_O     => GP_IO_CTRL_DATA_O,
						WB_SEL_I      => CORE_WB_SEL_O,
						WB_WE_I       => CORE_WB_WE_O,
						WB_STB_I      => GP_IO_CTRL_STB_I,
						WB_ACK_O      => GP_IO_CTRL_ACK_O,
						WB_HALT_O     => GP_IO_CTRL_HALT_O,
						WB_ERR_O      => GP_IO_CTRL_ERR_O,

						-- IO Port --
						GP_IO_O       => GP_IO_OUT_PORT,
						GP_IO_I       => (others => '0'),

						-- Input Change INT --
						IO_IRQ_O      => open,
--                        up => s_up,
--                        down => s_down,

						
						lcd_e         => lcd_e,
						lcd_rs        => lcd_rs,
						lcd_db        => lcd_db
				 );
				 
 

---start of the clock----------------
process(MAIN_CLK)
  
begin

  if rising_edge(MAIN_CLK) then
     if start = '0' or keep_entry = '1' then
        s_start <= '1';
        keep_entry <= '1';
        if stop = '0' or step = '0' or MAIN_RST = '0' then    
           keep_entry <= '0';
        end if;
     else
        s_start <= '0';
     end if;
   end if;
end process;

---stop of the clock----------
process(MAIN_CLK)

begin

	if rising_edge(MAIN_CLK) then
		if stop = '0' or keep_entry = '1' then
			s_stop <= '1';
			keep_entry_1 <= '1';
			if start = '0' or step = '0' or MAIN_RST = '0' then	
				keep_entry_1 <= '0';
			end if;
		else
			s_stop <= '0';
		end if;
	end if;
end process;

---step of the clock----------------
process(MAIN_CLK)
variable pulse_var : std_logic := '0';
variable pulse_counter : integer := 0;
begin
	if rising_edge(MAIN_CLK) then
		db1 <= step;
		db2 <= db1;
		db3 <= db2;
		if (db3 = '0' and db2 = '0' and db1 = '0') then
			s_step_db <= '1';
		else
			s_step_db <= '0';
		end if;
		s_step_db_last <= s_step_db;
		if ((s_step_db_last = '0' and s_step_db = '1') or pulse_var = '1') and pulse_counter /= 2 then
			pulse_counter := pulse_counter + 1;
			pulse_var := '1';
			s_step <= '1';
		else
			s_step <= '0';
			if pulse_counter = 2 then
				pulse_counter := 0;
				pulse_var := '0';
			end if;
		end if;
	end if;
end process;

---Processor clock generation------
process(MAIN_CLK)
begin
if rising_edge(MAIN_CLK) then
	s_exe <= (s_start or s_step) and not s_stop;
	if s_exe = '1' then
		Clk <= not Clk;
	end if;
end if;
end process;


---Reset--------------
--process(MAIN_RST,MAIN_CLK)
--begin
--	if MAIN_RST = '0' then
--        GP_IO_O_S  <= (others => '0');
--	elsif rising_edge(MAIN_CLK) then
--	   GP_IO_O_S  <= GP_IO_OUT_PORT;
--	end if;
--end process;

--s_Rst_n <= '0' when (MAIN_RST = '0') else '1';

-------------------------------------------
--process(MAIN_CLK)
--variable pulse_var : std_logic := '0';
--variable pulse_counter : integer := 0;
--begin
--	if rising_edge(MAIN_CLK) then
--		db4 <= up;
--		db5 <= db4;
--		db6 <= db5;
--		if (db6 = '0' and db5 = '0' and db4 = '0') then
--			s_up_db <= '1';
--		else
--			s_up_db <= '0';
--		end if;
--		s_up_db_last <= s_up_db;
--		if ((s_up_db_last = '0' and s_up_db = '1') or pulse_var = '1') and pulse_counter /= 2 then
--			pulse_counter := pulse_counter + 1;
--			pulse_var := '1';
--			s_up <= '1';
--		else
--			s_up <= '0';
--			if pulse_counter = 2 then
--				pulse_counter := 0;
--				pulse_var := '0';
--			end if;
--		end if;
--	end if;
--end process;

-------------------------------------------------------------------
--process(MAIN_CLK)
--variable pulse_var : std_logic := '0';
--variable pulse_counter : integer := 0;
--begin
--	if rising_edge(MAIN_CLK) then
--		db7 <= up;
--		db8 <= db7;
--		db9 <= db8;
--		if (db9 = '0' and db8 = '0' and db7 = '0') then
--			s_down_db <= '1';
--		else
--			s_down_db <= '0';
--		end if;
--		s_down_db_last <= s_down_db;
--		if ((s_down_db_last = '0' and s_down_db = '1') or pulse_var = '1') and pulse_counter /= 2 then
--			pulse_counter := pulse_counter + 1;
--			pulse_var := '1';
--			s_down <= '1';
--		else
--			s_down <= '0';
--			if pulse_counter = 2 then
--				pulse_counter := 0;
--				pulse_var := '0';
--			end if;
--		end if;
--	end if;
--end process;
			
end Structure;