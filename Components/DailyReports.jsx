"use client";
import { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/Firebase";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export default function DailyReports() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchReports = async () => {
      try {
        setLoading(true); // Start the loader
        const querySnapshot = await getDocs(collection(db, "dailyReports"));
        const reportsArray = [];
        querySnapshot.forEach((doc) => {
          reportsArray.push({ id: doc.id, ...doc.data() });
        });
        setReports(reportsArray);
        setLoading(false); // Stop the loader
        console.log(reports);
      } catch (error) {
        console.error("Error fetching reports:", error);
        setLoading(false); // Stop the loader on error
      }
    };

    fetchReports();
  }, []);

  return (
    <div>
      {loading ? (
        // Skeleton Loader - Multiple skeletons to match list structure
        <div className="space-y-4">
          {[...Array(5)].map((_, index) => (
            <div key={index} className="">
              <Skeleton className="h-4 w-[150px] mb-2" /> {/* Name skeleton */}
              <Skeleton className="h-4 w-[200px] mb-2" /> {/* Email skeleton */}
              <Skeleton className="h-4 w-[100px] mb-2" /> {/* Date skeleton */}
              <Skeleton className="h-4 w-[100px] mb-2" /> {/* Time skeleton */}
              <Skeleton className="h-6 w-full rounded-md" />{" "}
              {/* Description skeleton */}
            </div>
          ))}
        </div>
      ) : reports.length > 0 ? (
        // Actual content rendering
        <Table>
          <TableCaption>A list of daily reports.</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Time</TableHead>
              <TableHead>Description</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {reports.map((report) => (
              <TableRow key={report.id}>
                <TableCell className="font-medium">{report.name}</TableCell>
                <TableCell>{report.email}</TableCell>
                <TableCell>{report.formatted_date}</TableCell>
                <TableCell>{report.full_time}</TableCell>
                <TableCell>{report.desc}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <p>No reports found</p>
      )}
    </div>
  );
}
