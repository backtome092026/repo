import {cookies} from "next/headers";
import {NextResponse} from "next/server";

const roles=["student","parent","staff","admin"] as const;

export async function POST(request:Request){
  const {role}=await request.json() as {role?:string};
  if(!roles.includes(role as typeof roles[number]))return NextResponse.json({message:"Choose a valid role."},{status:400});
  const jar=await cookies();
  jar.set("back2me_demo_role",role!,{httpOnly:true,secure:process.env.NODE_ENV==="production",sameSite:"lax",path:"/",maxAge:60*60*8});
  return NextResponse.json({ok:true});
}

export async function DELETE(){
  const jar=await cookies();
  jar.delete("back2me_demo_role");
  return NextResponse.json({ok:true});
}
