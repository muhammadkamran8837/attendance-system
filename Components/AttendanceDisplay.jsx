"use client";
import React, { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/Firebase"; // Ensure the path is correct to your Firebase config
import { Skeleton } from "./ui/skeleton";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";

export default function AttendanceDisplay() {
  const [attendances, setAttendances] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchAttendance = async () => {
      try {
        setLoading(true); // Start the loader
        const querySnapshot = await getDocs(collection(db, "attendance"));
        const attendanceArray = [];
        querySnapshot.forEach((doc) => {
          attendanceArray.push({ id: doc.id, ...doc.data() });
        });

        // Sort by formatted_date in descending order (newest first)
        attendanceArray.sort(
          (a, b) => new Date(b.formatted_date) - new Date(a.formatted_date)
        );

        setAttendances(attendanceArray);
        setLoading(false); // Stop the loader
        console.log(attendanceArray);
      } catch (error) {
        console.error("Error fetching attendance:", error);
        setLoading(false); // Stop the loader on error
      }
    };

    fetchAttendance();
  }, []);

  return (
    <div>
      {loading ? (
        // Skeleton Loader - Multiple skeletons to match table structure
        <div className="space-y-4">
          {[...Array(5)].map((_, index) => (
            <div key={index} className="">
              <Skeleton className="h-4 w-[150px] mb-2" /> {/* ID skeleton */}
            </div>
          ))}
        </div>
      ) : attendances.length > 0 ? (
        // Actual content rendering
        <Table>
          <TableCaption>Attendance Records</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Email</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Time</TableHead>
              <TableHead>Mode</TableHead>
              <TableHead>Comment</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {attendances.map((attendance) => (
              <TableRow key={attendance.id}>
                <TableCell>{attendance.email}</TableCell>
                <TableCell>{attendance.name}</TableCell>
                <TableCell>{attendance.formatted_date}</TableCell>
                <TableCell>{attendance.full_time}</TableCell>
                <TableCell>{attendance.mode}</TableCell>
                <TableCell>{attendance.comment}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <p>No attendance records found</p>
      )}
    </div>
  );
}
