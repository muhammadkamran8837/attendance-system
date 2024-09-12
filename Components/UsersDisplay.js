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
} from "@/components/ui/table";

export default function UsersDisplay() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);

  // Fetch data from Firebase
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true); // Show loader while fetching data
        const querySnapshot = await getDocs(collection(db, "users")); // Fetch data from 'users' collection
        const usersArray = [];
        querySnapshot.forEach((doc) => {
          usersArray.push({ id: doc.id, ...doc.data() });
        });
        setUsers(usersArray);
        setLoading(false); // Stop loader
      } catch (error) {
        console.error("Error fetching users:", error);
        setLoading(false); // Stop loader on error
      }
    };

    fetchUsers();
  }, []);

  return (
    <div>
      {loading ? (
        // Show skeleton loader while data is loading
        <div className="space-y-4">
          {[...Array(5)].map((_, index) => (
            <div key={index} className="">
              <Skeleton className="h-4 w-[150px] mb-2" /> {/* Name skeleton */}
              <Skeleton className="h-4 w-[200px] mb-2" /> {/* Email skeleton */}
              <Skeleton className="h-4 w-[100px] mb-2" />{" "}
              {/* Department skeleton */}
              <Skeleton className="h-6 w-full rounded-md" />
              {/* Status skeleton */}
            </div>
          ))}
        </div>
      ) : users.length > 0 ? (
        // Actual table displaying user data
        <Table>
          <TableCaption>List of Users</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Image</TableHead>
              <TableHead>ID</TableHead>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Department</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {users.map((user) => (
              <TableRow key={user.id}>
                <TableCell>
                  {/*eslint-disable-next-line @next/next/no-img-element  */}
                  <img
                    src={user.image || "https://via.placeholder.com/50"}
                    alt={user.name}
                    style={{
                      width: "30px",
                      height: "30px",
                      borderRadius: "50%",
                    }}
                  />
                </TableCell>
                <TableCell className="font-medium">{user.id_number}</TableCell>
                <TableCell>{user.name}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>{user.department}</TableCell>
                <TableCell>{user.emp_status ? "Active" : "Inactive"}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <p>No users found</p>
      )}
    </div>
  );
}
