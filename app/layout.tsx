import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Back2Me — Lost & found, sorted.", template: "%s | Back2Me" },
  description: "A searchable, measurable lost-and-found recovery system for schools.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
