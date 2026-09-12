"use client";

import Link from "@/components/native-link";
import {useRouter} from "next/navigation";
import {GraduationCap,HeartHandshake,LayoutDashboard,School,Search,Sparkles,Users} from "lucide-react";

const links=[
  {href:"/student/dashboard",label:"Student",icon:GraduationCap},
  {href:"/parent/dashboard",label:"Parent",icon:HeartHandshake},
  {href:"/staff/dashboard",label:"Staff & admin",icon:LayoutDashboard},
  {href:"/search",label:"Find",icon:Search},
  {href:"/give",label:"Give",icon:School},
  {href:"/good",label:"Good wall",icon:Sparkles},
  {href:"/innovate",label:"Innovate",icon:Sparkles},
  {href:"/people",label:"People",icon:Users},
];

export function DemoAccessBar({role}:{role:string}){
  const router=useRouter();
  async function logout(){await fetch("/api/demo/session",{method:"DELETE"});router.push("/");router.refresh()}
  return <div className="no-print fixed inset-x-0 top-0 z-[100] flex h-14 items-center gap-2 border-b border-indigo-300 bg-[#192b67] px-3 text-white shadow-lg">
    <div className="hidden shrink-0 items-center gap-2 pr-2 sm:flex"><span className="rounded-full bg-amber-300 px-2.5 py-1 text-[11px] font-black uppercase tracking-wider text-[#192b67]">Demo mode</span><span className="text-xs font-bold capitalize text-indigo-100">{role}</span></div>
    <nav className="flex min-w-0 flex-1 items-center gap-1 overflow-x-auto">{links.map(link=><Link key={link.href} href={link.href} className="flex shrink-0 items-center gap-1.5 rounded-lg px-2.5 py-2 text-xs font-bold text-indigo-50 hover:bg-white/15 hover:text-white"><link.icon className="size-4"/>{link.label}</Link>)}</nav>
    <Link href="/demo" className="shrink-0 rounded-lg border border-white/20 px-3 py-2 text-xs font-black hover:bg-white/10">Change role</Link>
    <button type="button" onClick={logout} className="shrink-0 rounded-lg bg-[#ff6f61] px-3 py-2 text-xs font-black hover:bg-[#e85e52]">Logout</button>
  </div>
}
