import Link from "next/link";
import {ArrowLeft,Sparkles} from "lucide-react";
import {Brand} from "@/components/brand";
import {DemoRolePicker} from "@/components/demo-role-picker";

export default function Demo(){return <main className="paper-grid min-h-screen px-5 py-8 sm:py-12"><div className="mx-auto max-w-4xl"><div className="flex items-center justify-between gap-4"><Brand/><Link href="/" className="inline-flex items-center gap-2 text-sm font-bold text-slate-500 hover:text-indigo-700"><ArrowLeft className="size-4"/>Back home</Link></div><div className="mx-auto mt-10 max-w-2xl rounded-[2rem] border bg-white p-6 shadow-2xl shadow-indigo-100/60 sm:p-10"><div className="mb-7 text-center"><span className="mx-auto grid size-14 place-items-center rounded-2xl bg-amber-100 text-amber-700"><Sparkles/></span><h1 className="mt-4 text-4xl font-black tracking-[-.04em] text-[#192b67]">Explore Back2Me</h1></div><DemoRolePicker/></div></div></main>}
