import AttendanceDisplay from "@/Components/AttendanceDisplay";
import DailyReports from "@/Components/DailyReports";
import StaffDisplay from "@/Components/StaffDisplay";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/Components/ui/tabs";
import UsersDisplay from "@/Components/UsersDisplay";
import React from "react";

export default function TabsComponent() {
  return (
    <Tabs defaultValue="dailyReports" className="w-[100%]">
      <TabsList>
        <TabsTrigger value="dailyReports">Daily Reports</TabsTrigger>
        <TabsTrigger value="Attendance">Attendance</TabsTrigger>
        <TabsTrigger value="Staff">Staff</TabsTrigger>
        <TabsTrigger value="Users">Users</TabsTrigger>
      </TabsList>
      <div className="border-solid border-[1px] rounded-md border-slate-200 px-5 mt-2 h-[85vh] overflow-y-auto">
        <TabsContent value="dailyReports">
          <DailyReports />
        </TabsContent>
        <TabsContent value="Attendance">
          <AttendanceDisplay />
        </TabsContent>
        <TabsContent value="Staff">
          <StaffDisplay />
        </TabsContent>
        <TabsContent value="Users">
          <UsersDisplay />
        </TabsContent>
      </div>
    </Tabs>
  );
}
