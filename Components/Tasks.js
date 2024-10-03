"use client";
import React, { useState, useEffect } from "react";
import { Button } from "@/Components/ui/button";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/Components/ui/table";
import { AddNewTask } from "./AddNewTask";
import { collection, getDocs } from "firebase/firestore";
import { db } from "@/config/Firebase";

export default function Tasks() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);

      try {
        const tasksArray = [];

        // Fetch all documents (employIds) from the root "task" collection
        const taskCollectionSnapshot = await getDocs(collection(db, "task"));

        // Loop through each employId document
        for (const employDoc of taskCollectionSnapshot.docs) {
          const employId = employDoc.id;

          // Fetch the "task" subcollection for each employId
          const taskSubCollectionSnapshot = await getDocs(
            collection(db, "task", employId, "task")
          );

          // Loop through the tasks in each subcollection and push them to the tasksArray
          taskSubCollectionSnapshot.forEach((doc) => {
            tasksArray.push({
              employId: employId, // Keep track of the employId
              id: doc.id,
              ...doc.data(),
            });
          });
        }

        setTasks(tasksArray);
      } catch (error) {
        console.error("Error fetching tasks:", error);
        setError("Failed to load tasks. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="">
      <div className="flex items-center justify-end mb-2">
        <AddNewTask />
      </div>

      {loading ? (
        <p>Loading tasks...</p>
      ) : error ? (
        <p className="text-red-500">{error}</p>
      ) : tasks.length > 0 ? (
        <div>
          <Table>
            <TableCaption>Assigned Tasks</TableCaption>
            <TableHeader>
              <TableRow>
                <TableHead>Employ ID</TableHead>
                <TableHead>Task Title</TableHead>
                <TableHead>Task Description</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {tasks.map((task) => (
                <TableRow key={task.id}>
                  <TableCell>{task.employId}</TableCell>
                  <TableCell>{task.title}</TableCell>
                  <TableCell>{task.description}</TableCell>
                  <TableCell>{task.done ? "Done" : "Pending"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      ) : (
        <p>No tasks found.</p>
      )}
    </div>
  );
}
