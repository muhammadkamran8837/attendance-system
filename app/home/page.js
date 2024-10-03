"use client";
import React, { useEffect, useState } from "react";
import TabsComponent from "./TabsComponent";
import { useRouter } from "next/navigation";

export default function Home() {
  const [loading, setLoading] = useState(true); // State to manage loading
  const router = useRouter();

  useEffect(() => {
    const isLoggedIn = localStorage.getItem("isLoggedIn");

    // If not logged in, redirect to login page
    if (!isLoggedIn) {
      router.replace("/");
    } else {
      setLoading(false); // Stop loading if logged in
    }
  }, [router]);

  // Show nothing (or a loading spinner) until login check is complete
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Checking authentication...</p>
      </div>
    );
  }

  // If user is logged in, show the content
  return (
    <div className="px-5 md:px-8 py-5">
      <TabsComponent />
    </div>
  );
}
