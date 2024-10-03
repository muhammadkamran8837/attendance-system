"use client";
import React, { useState } from "react";
import { useRouter } from "next/navigation";
const EMAIL = "admin@example.com";
const PASSWORD = "fyp2024";
export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const route = useRouter();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError(""); // Reset previous error state
    setLoading(true);

    if (!email || !password) {
      alert("Please enter email and password");
      setLoading(false);
      return;
    }

    if (email === EMAIL && password === PASSWORD) {
      localStorage.setItem("isLoggedIn", "true"); // Set the login flag

      setLoading(false);
      route.push("/home"); // Navigate to home page on successful login
    } else {
      alert("Invalid credentials!");
      setLoading(false);
      return;
    }
  };
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 px-10">
      <div className="bg-white shadow-lg rounded-lg px-8 py-4 max-w-md w-full">
        <h2 className="text-3xl font-bold text-center text-darkBlue mb-8">
          Welcome back
        </h2>
        {error && <p className="text-red-500 text-center mb-4">{error}</p>}
        {/* Error display */}
        {/* Login Form */}
        <form>
          {/* Email Input */}
          <div className="mb-6">
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Email Address
            </label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500 focus:outline-none"
              placeholder="Enter your email"
              required
            />
          </div>

          {/* Password Input */}
          <div className="mb-6">
            <label
              htmlFor="password"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Password
            </label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md text-sm focus:ring-blue-500 focus:border-blue-500 focus:outline-none"
              placeholder="Enter your password"
              required
            />
          </div>

          {/* Forgot Password Link */}
          {/* <div className="flex justify-between items-center mb-6">
            <a href="#" className="text-sm text-blue-500 hover:underline">
              Forgot Password?
            </a>
          </div> */}

          {/* Submit Button */}
          <button
            onClick={handleLogin}
            className="w-full py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50"
            disabled={loading}
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
}
