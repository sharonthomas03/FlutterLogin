import React from "react";

type StatCardProps = {
  title: string;
  value: string | number | undefined | null;
  icon?: React.ReactNode;
  gradient?: string;
  subtitle?: string;
};

export default function StatCard({ title, value, icon, gradient, subtitle }: StatCardProps) {
  return (
    <div className="relative overflow-hidden rounded-2xl bg-slate-800 border border-slate-700 p-6 shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition-all duration-300 group">
      {/* Background gradient orb */}
      <div
        className={`absolute -top-4 -right-4 w-24 h-24 rounded-full blur-2xl opacity-20 group-hover:opacity-30 transition-opacity duration-300 ${gradient}`}
      />

      <div className="relative flex items-start justify-between">
        <div className="flex-1">
          <p className="text-slate-400 text-sm font-medium uppercase tracking-wider mb-1">
            {title}
          </p>
          <p className="text-4xl font-bold text-white mt-2 tabular-nums">
            {value !== undefined && value !== null ? value.toLocaleString() : "—"}
          </p>
          {subtitle && (
            <p className="text-slate-500 text-xs mt-2">{subtitle}</p>
          )}
        </div>
        <div
          className={`flex items-center justify-center w-12 h-12 rounded-xl text-white shadow-lg ${gradient}`}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}
