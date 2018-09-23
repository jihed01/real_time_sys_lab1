--Cyclic scheduler with a watchdog: 

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

-- add packages to use randam number generator


procedure cyclic_wd is
    Message: constant String := "Cyclic scheduler with watchdog";
	Start_Time: Time := Clock;
	Start_Wait: Time;
	counter: Integer := 0;  	
        G: Generator;
	
	
	procedure f1 is 
		Message: constant String := "f1 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f1;

	procedure f2 is 
		Message: constant String := "f2 executing, time is now";
	begin
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));
	end f2;

	procedure f3 is 
		Message: constant String := "f3 executing, time is now";
	begin			
		Put(Message);
		Put_Line(Duration'Image(Clock - Start_Time));

		-- Random delay to make f3 occasionally have too long execution time
		delay Duration(Random(G));
		Reset(G); 		
	end f3;
	
	task Watchdog is
		entry start; -- TODO: Add comment
		entry stop(Start_wait: in Time); -- TODO: Add comment	 	   	
	end Watchdog;

	task body Watchdog is
		start_flag: Boolean := False;
	begin
		loop
 			select	
				-- Indicates that f3 is about to start executing 
				accept start do
					start_flag := True; 
				end start;
			or	
				-- Indicates that f3 finish executing in time 
				when (start_flag) =>	
					accept stop(Start_wait: in Time) do
						start_flag := False;
						delay until Start_Wait + 1.0;
					end stop;
			or
				-- Indicates that f3 took longer then 0.5 seconds to execute
				when (start_flag) =>						
					delay 0.5;
					start_flag := False;
					put_line("f3's execution time was too long!");
					accept stop(Start_wait: in Time) do
						delay until Start_wait + 2.0;
					end stop;
					
			end select;
			
		end loop;
	end Watchdog;

	begin

        loop -- TODO: Remove drift  
              	Start_Wait := Clock;					
		f1;
                f2;

		delay until Start_Wait + 0.5;

		Watchdog.start;

		-- Ensures that f3 is executed every other second
		if (counter mod 2 = 0) then	
                	f3;	  
		end if;

		Watchdog.stop(Start_wait);
		
		counter := counter + 1;      
        end loop;
end cyclic_wd;
