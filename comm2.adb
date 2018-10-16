--Protected types: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm2 is
    Message: constant String := "Protected Object";
    	type BufferArray is array (1 .. 10) of Integer;
	buffer_array: BufferArray;

	protected  buffer is
		entry read(value: out Integer); -- Used to retrive an item from the buffer
		entry write(value: in Integer); -- Used to insert an item into the buffer

	private
		index: Integer := 0; 
	
	end buffer;

	task producer is
		entry quit; -- Used to end the buffer
	end producer;

	task consumer is
                
	end consumer;

		
	protected body buffer is 

		-- Retrieves the first value in the buffer array and removes it from the buffer
		entry read(value: out Integer)
			when index > 0 is
		begin				
			value := buffer_array(1);
			For_Loop:
				for i in Integer range 1 .. 9 loop
					buffer_array(i) := buffer_array(i + 1);
				end loop For_Loop; 
			index := index - 1;
		end read;

		-- Set the the received value at the end of the buffer array
		entry write(value: in Integer)
			when index < 10 is
		begin			
			index := index + 1;
			buffer_array(index) := value;
		end write;
	end buffer;


        task body producer is 
		Message: constant String := "producer executing";

		-- Setting up the random generator between 0 - 25
		subtype rand_range is Integer range 0 .. 25;
   		package rand_value is new Ada.Numerics.Discrete_Random (rand_range);
   		use rand_value;
		G: Generator;

		value: Integer;
		exit_flag: Boolean := False;  
	begin
		Put_Line(Message);
		loop
			-- Exit the task when the exit_flag is True
			if (exit_flag) then
				exit;			
			end if;

			Select		
				-- Sets the exit flag to true so that the producer will end the next iteration		
				accept quit do
					exit_flag := True;
				end quit;
			or
				-- If 'quit' is not received then a random number is generated and sent to the buffer
				delay 0.05;
				value := Random(G); 			 
				buffer.write(value);
				put_line("Producer sent the following value to buffer: " & Integer'Image(value));
	   			Reset(G);
			end select;
		end loop;
	end producer;


	task body consumer is 
		Message: constant String := "consumer executing";

		-- Setting up a random Integer generator between 0 - 1
		subtype rand_range is Integer range 0 .. 1;
   		package rand_value is new Ada.Numerics.Discrete_Random (rand_range);
   		use rand_value;
		G: Generator;

		value: Integer := 0;
		total: Integer := 0; 
	begin
		Put_Line(Message);
		Main_Cycle:
		loop 			
			-- Retreive a number from the buffer and add it to the total
			buffer.read(value); 
			put_line("Consumer recived the following value from buffer: " & Integer'Image(value));	
			total := total + value; 

			if (total >= 100) then
				exit;
			end if;

			-- Delay either 0.0 or 0.5 seconds so that the producer have time to fill up the buffer 
			delay Duration(float(Random(G)) - 0.5);
			Reset(G); 
		end loop Main_Cycle; 
   
		Put_Line("Ending the consumer");

		-- End the other tasks
		producer.quit;
		
	end consumer;

begin
Put_Line(Message);
end comm2;
