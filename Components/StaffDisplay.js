"use client";
import { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "@/config/Firebase";
import { Skeleton } from "@/Components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/Components/ui/table";

export default function StaffDisplay() {
  const [staffs, setStaffs] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchStaffs = async () => {
      try {
        setLoading(true); // Start the loader
        const querySnapshot = await getDocs(collection(db, "staffs"));
        const staffArray = [];
        querySnapshot.forEach((doc) => {
          staffArray.push({ id: doc.id, ...doc.data() });
        });
        setStaffs(staffArray);
        setLoading(false); // Stop the loader
        console.log(staffArray);
      } catch (error) {
        console.error("Error fetching staff:", error);
        setLoading(false); // Stop the loader on error
      }
    };

    fetchStaffs();
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
      ) : staffs.length > 0 ? (
        // Actual content rendering
        <Table>
          <TableCaption>A list of staff IDs.</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Staff ID</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {staffs.map((staff) =>
              staff.id_number.map((id, index) => (
                <TableRow key={`${staff.id}-${index}`}>
                  <TableCell className="font-medium">{id}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      ) : (
        <p>No staff members found</p>
      )}
    </div>
  );
}
