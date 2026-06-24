"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";

type ProtectedRouteProps = {
  children: React.ReactNode;
};

/**
 * Wraps any page that requires a valid auth session.
 * - If neither accessToken nor refreshToken exists → redirect to /login.
 * - If tokens exist → render children.
 *   (If accessToken is expired but refreshToken is still valid, authApiCall
 *    will transparently refresh it when the first API call fires.)
 */
export default function ProtectedRoute({ children }: ProtectedRouteProps) {
  const router = useRouter();
  const [isAuthorized, setIsAuthorized] = useState<boolean>(false);

  useEffect(() => {
    const accessToken = localStorage.getItem("accessToken");
    const refreshToken = localStorage.getItem("refreshToken");

    // If neither token exists, the session is fully expired — go to login.
    // If at least one token is present, let the API layer decide whether
    // to silently refresh or redirect when the first authenticated call fires.
    if (!accessToken && !refreshToken) {
      router.replace("/login");
    } else {
      setIsAuthorized(true);
    }
  }, [router]);

  if (!isAuthorized) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-900">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-4 border-violet-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-slate-400 text-sm">Verifying access...</p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
