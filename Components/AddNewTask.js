import { useEffect, useState } from "react";
import { Button } from "@/Components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/Components/ui/dialog";
import { Input } from "@/Components/ui/input";
import { Label } from "@/Components/ui/label";
import {
  collection,
  getDocs,
  addDoc,
  doc,
  getDoc,
  setDoc,
} from "firebase/firestore";
import { db } from "@/config/Firebase"; // Make sure your firebase config is correct

export function AddNewTask() {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState("");
  const [taskTitle, setTaskTitle] = useState("");
  const [taskDescription, setTaskDescription] = useState("");
  const [loading, setLoading] = useState(false);

  // Fetch all users from Firestore
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true);
        const querySnapshot = await getDocs(collection(db, "users"));
        const usersArray = [];
        querySnapshot.forEach((doc) => {
          usersArray.push({ id: doc.id, ...doc.data() });
        });
        setUsers(usersArray);
        setLoading(false); // Stop loader
      } catch (error) {
        console.error("Error fetching users: ", error);
        setLoading(false);
      }
    };
    fetchUsers();
  }, []);

  // Handle form submission to assign task
  const handleAssignTask = async (e) => {
    e.preventDefault();
    if (!selectedUser || !taskTitle || !taskDescription) {
      alert("Please fill out all fields.");
      return;
    }

    try {
      // Check if the user document exists
      const userDocRef = doc(db, "task", selectedUser);
      const userDoc = await getDoc(userDocRef);

      if (!userDoc.exists()) {
        // If the user document doesn't exist, create it (or initialize it with empty data)
        await setDoc(userDocRef, {});
      }

      // Now, proceed to add the task in the subcollection
      const taskCollectionRef = collection(db, "task", selectedUser, "task");
      await addDoc(taskCollectionRef, {
        title: taskTitle,
        description: taskDescription,
        done: false, // default status
      });
      alert("Task assigned successfully!");

      // Reset form
      setSelectedUser("");
      setTaskTitle("");
      setTaskDescription("");
    } catch (error) {
      console.error("Error assigning task: ", error);
    }
  };
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>Assign New Task</Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>New Task</DialogTitle>
          <DialogDescription>
            Select a user and assign a task to them. Click save when you are
            done.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleAssignTask}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="user" className="text-right">
                Select User
              </Label>
              <select
                id="user"
                value={selectedUser}
                onChange={(e) => setSelectedUser(e.target.value)}
                className="col-span-3 p-2 border rounded-md"
              >
                <option value="">Select a user</option>
                {loading ? (
                  <option>Loading users...</option>
                ) : (
                  users.map((user) => (
                    <option key={user.id_number} value={user.id_number}>
                      {user.name || "No Name"} ({user.id_number})
                    </option>
                  ))
                )}
              </select>
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="title" className="text-right">
                Task Title
              </Label>
              <Input
                id="title"
                value={taskTitle}
                onChange={(e) => setTaskTitle(e.target.value)}
                className="col-span-3"
                placeholder="Enter task title"
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="description" className="text-right">
                Description
              </Label>
              <Input
                id="description"
                value={taskDescription}
                onChange={(e) => setTaskDescription(e.target.value)}
                className="col-span-3"
                placeholder="Enter task description"
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit">Save Task</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
