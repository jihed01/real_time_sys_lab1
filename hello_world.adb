-- File: hello_world. adb
  with Ada.Text_IO ; -- Use package Ada.Text_IO
  use Ada.Text_IO ;   -- Integrate its namespace

  procedure hello_world is
      Message : constant String := " Hello World " ;
  begin
      Put_Line(Item => Message) ;
  end hello_world ;
