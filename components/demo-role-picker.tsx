"use client";

import {useState} from "react";
import {useRouter, useSearchParams} from "next/navigation";
import {GraduationCap,HeartHandshake,Loader2,School,ShieldCheck} from "lucide-react";
import {Button} from "@/components/ui/button";

const roles=[
  {id:"student",label:"Student",description:"Find items, give, celebrate kindness, and innovate.",icon:GraduationCap,destination:"/student/dashboard",color:"bg-sky-50 text-sky-700 border-sky-200"},
  {id:"parent",label:"Parent",description:"See the parent experience and school community.",icon:HeartHandshake,destination:"/parent/dashboard",color:"bg-rose-50 text-rose-700 border-rose-200"},
  {id:"staff",label:"School staff",description:"Manage items, claims, people, and safety.",icon:ShieldCheck,destination:"/staff/dashboard",color:"bg-amber-50 text-amber-800 border-amber-200"},
  {id:"admin",label:"School admin",description:"Explore every operational and settings screen.",icon:School,destination:"/staff/dashboard",color:"bg-indigo-50 text-indigo-700 border-indigo-200"},
] as const;

export function DemoRolePicker(){
  const [busy,setBusy]=useState<string|null>(null),[error,setError]=useState("");
  const router=useRouter(),params=useSearchParams();
  async function enter(role:typeof roles[number]){
    setBusy(role.id);setError("");
    try{
      const response=await fetch("/api/demo/session",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({role:role.id})});
      if(!response.ok)throw new Error();
      const next=params.get("next");
      router.push(next?.startsWith("/")?next:role.destination);
      router.refresh();
    }catch{setError("Demo access could not start. Please try again.");setBusy(null)}
  }
  return <section className="mb-8 rounded-3xl border-2 border-indigo-200 bg-gradient-to-br from-indigo-50 via-white to-rose-50 p-5 shadow-sm">
    <div className="flex items-start gap-3"><span className="grid size-11 shrink-0 place-items-center rounded-2xl bg-[#5267d9] text-white"><School className="size-5"/></span><div><p className="text-xs font-black uppercase tracking-[.16em] text-indigo-600">Demo access</p><h2 className="text-xl font-black text-[#192b67]">How would you like to explore?</h2><p className="mt-1 text-sm text-slate-600">No account is needed during the demo. You can visit every section after choosing a role.</p></div></div>
    <div className="mt-5 grid gap-3 sm:grid-cols-2">{roles.map(role=>{const Icon=role.icon;return <Button key={role.id} type="button" variant="outline" disabled={Boolean(busy)} onClick={()=>enter(role)} className={`h-auto justify-start gap-3 whitespace-normal border p-4 text-left ${role.color}`}><Icon className="size-6 shrink-0"/><span><strong className="block">{role.label}</strong><span className="mt-0.5 block text-xs font-medium opacity-80">{role.description}</span></span>{busy===role.id&&<Loader2 className="ml-auto size-4 animate-spin"/>}</Button>})}</div>
    {error&&<p role="alert" className="mt-3 rounded-xl bg-rose-100 p-3 text-sm font-bold text-rose-700">{error}</p>}
  </section>
}
