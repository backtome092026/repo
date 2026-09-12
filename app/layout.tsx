import type { Metadata } from "next";
import { cookies } from "next/headers";
import { DemoAccessBar } from "@/components/demo-access-bar";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Back2Me — Lost & found, sorted.", template: "%s | Back2Me" },
  description: "A searchable, measurable lost-and-found recovery system for schools.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const demoRole=(await cookies()).get("back2me_demo_role")?.value;
  const demoActive=["student","parent","staff","admin"].includes(demoRole||"");
  return (
    <html lang="en">
      <body className="antialiased">
        {demoActive&&<DemoAccessBar role={demoRole!}/>}
        <div className={demoActive?"pt-14":""}>{children}</div>
      </body>
    </html>
  );
}
