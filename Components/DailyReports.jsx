"use client";
import { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../config/Firebase";

export default function DailyReports() {
  const [reports, setReports] = useState([]);

  useEffect(() => {
    const fetchReports = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "dailyReports"));
        const reportsArray = [];
        querySnapshot.forEach((doc) => {
          reportsArray.push({ id: doc.id, ...doc.data() });
        });
        setReports(reportsArray);
      } catch (error) {
        console.error("Error fetching reports:", error);
      }
    };

    fetchReports();
  }, []);
  return (
    <div>
      <h1>Daily Reports</h1>
      {reports.length > 0 ? (
        <ul>
          {reports.map((report) => (
            <li key={report.id}>
              <p>Name: {report.name}</p>
              <p>Email: {report.email}</p>
              <p>Date: {report.formatted_date}</p>
              <p>Time: {report.full_time}</p>
              <p>Description: {report.desc}</p>
            </li>
          ))}
        </ul>
      ) : (
        <p>No reports found</p>
      )}
    </div>
  );
}
