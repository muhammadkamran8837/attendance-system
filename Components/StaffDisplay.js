
"use client";
import { useEffect, useState } from "react";
import { collection, doc, getDoc, updateDoc, arrayUnion } from "firebase/firestore";
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
  const [showModal, setShowModal] = useState(false); // For modal visibility
  const [newStaff, setNewStaff] = useState(""); // For new staff ID input
  const [formError, setFormError] = useState(""); // To handle form validation
  const [staffDocId] = useState("ids"); // Assuming the document ID is "ids"

  useEffect(() => {
    const fetchStaffs = async () => {
      try {
        setLoading(true);
        const docRef = doc(db, "staffs", staffDocId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
          setStaffs(docSnap.data().id_number);
        } else {
          console.error("Document does not exist");
        }
        setLoading(false);
      } catch (error) {
        console.error("Error fetching staff:", error);
        setLoading(false);
      }
    };

    fetchStaffs();
  }, [staffDocId]);

  // Function to handle adding a new staff member
  const handleAddStaff = async (e) => {
    e.preventDefault();

    if (!newStaff) {
      setFormError("Staff ID is required");
      return;
    }
    setFormError("");

    try {
      const docRef = doc(db, "staffs", staffDocId);
      await updateDoc(docRef, {
        id_number: arrayUnion(newStaff),
      });
      setShowModal(false); // Close the modal
      setNewStaff(""); // Clear form input

      // Refresh staff list
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setStaffs(docSnap.data().id_number);
      }
    } catch (error) {
      console.error("Error adding staff:", error);
    }
  };

  return (
    <div>
      <div className="flex justify-end mb-4">
        <button
          onClick={() => setShowModal(true)} // Show modal on button click
          className="bg-black text-white px-4 py-2 rounded"
        >
          Add New Staff
        </button>
      </div>

      {loading ? (
        <div className="space-y-4">
          {[...Array(5)].map((_, index) => (
            <div key={index} className="">
              <Skeleton className="h-4 w-[150px] mb-2" />
            </div>
          ))}
        </div>
      ) : staffs.length > 0 ? (
        <Table>
          <TableCaption>A list of staff IDs.</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Staff ID</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {staffs.map((id, index) => (
              <TableRow key={index}>
                <TableCell className="font-medium">{id}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <p>No staff members found</p>
      )}

      {/* Modal for adding new staff */}
      {showModal && (
        <div className="fixed inset-0 flex items-center justify-center z-50 bg-black bg-opacity-50">
          <div className="bg-white p-6 rounded-md shadow-lg w-96">
            <h2 className="text-lg font-semibold mb-4">Add New Staff</h2>
            <form onSubmit={handleAddStaff}>
              <label className="block mb-2">Staff ID:</label>
              <input
                type="text"
                value={newStaff}
                onChange={(e) => setNewStaff(e.target.value)}
                className="border p-2 w-full mb-4"
              />
              {formError && (
                <p className="text-red-500 mb-2">{formError}</p>
              )}
              <div className="flex justify-end space-x-4">
                <button
                  type="button"
                  onClick={() => setShowModal(false)} // Close modal
                  className="bg-gray-300 px-4 py-2 rounded"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="bg-black text-white px-4 py-2 rounded"
                >
                  Add Staff
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
