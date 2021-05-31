with Ada.Command_Line;
with Ada.Calendar.Arithmetic;
--  with Ada.Containers.Bounded_Synchronized_Queues;
with Ada.Containers.Unbounded_Synchronized_Queues;
with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Text_IO; use Ada.Text_IO;

package body Workers
is

   type Element is tagged
      record
         Value : Integer;
      end record;

   procedure Main
   is
      Q_Size      : constant Ada.Containers.Count_Type :=
         Ada.Containers.Count_Type'Value (Ada.Command_Line.Argument (1));
      Iterations  : constant Integer := Integer'Value (Ada.Command_Line.Argument (2));
      Num_Workers : constant Integer := Integer'Value (Ada.Command_Line.Argument (3));

      package RQ_Interfaces is new Ada.Containers.Synchronized_Queue_Interfaces (Element);   
      package RQ_Package is new Ada.Containers.Unbounded_Synchronized_Queues (RQ_Interfaces);

      Requests : RQ_Package.Queue;

      task type Worker;

      task body Worker
      is
         Element : Workers.Element;
         use type Ada.Containers.Count_Type;
      begin
         loop
            Requests.Dequeue (Element);
            if Element.Value = 0 then
               exit;
            end if;
         end loop;
      end Worker;

      type Wrkrs is array (Natural range <>) of Worker;

      Unused              : Element;
      Start               : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      Unused_Days         : Ada.Calendar.Arithmetic.Day_Count;
      Unused_Leap_Seconds : Ada.Calendar.Arithmetic.Leap_Seconds_Count;
      Elapsed             : Duration;
      RPS                 : Float;
   begin
      declare
         Workers_Array       : Wrkrs (1 .. Num_Workers);
      begin
         for I in 1 .. Iterations 
         loop
            Requests.Enqueue ((Value => I));
         end loop;
         for I in 1 .. Num_Workers
         loop
            Requests.Enqueue ((Value => 0));
         end loop;
      end;
      Ada.Calendar.Arithmetic.Difference
         (Left         => Ada.Calendar.Clock,
          Right        => Start,
          Days         => Unused_Days,
          Seconds      => Elapsed,
          Leap_Seconds => Unused_Leap_Seconds);
      RPS := Float (Iterations) / Float (Elapsed);
          
      Put_Line (Num_Workers'Image & "," & Q_Size'Image & "," & Integer (RPS)'Image);
   end Main;

end Workers;
