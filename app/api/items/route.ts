import {NextResponse} from "next/server";
import {createClient} from "@/lib/supabase/server";

export async function POST(request:Request){
  try{
    const form=await request.formData(),value=(key:string)=>String(form.get(key)||""),supabase=await createClient();
    if(!value("description")||!value("category")||!value("color")||!value("foundDate"))return NextResponse.json({message:"Missing required fields"},{status:400});
    if(supabase){
      const base={p_category:value("category"),p_subcategory:value("subcategory")||null,p_description:value("description"),p_found_date:value("foundDate"),p_found_location:value("foundLocation"),p_public_location:value("publicLocation"),p_storage_location:value("storageLocation"),p_condition:value("condition"),p_estimated_value:Number(value("estimatedValue")||0),p_internal_notes:value("internalNotes")||null};
      let result=await supabase.rpc("create_found_item",{...base,p_color:value("color")});
      // Keeps color-search working during a rolling deploy before the color migration reaches production.
      if(result.error?.code==="PGRST202")result=await supabase.rpc("create_found_item",{...base,p_description:`${value("color")} ${value("description")}`});
      if(result.error)throw result.error;
      const id=result.data,photo=form.get("photo");
      if(photo instanceof File&&photo.size){
        const{data:{user}}=await supabase.auth.getUser();if(!user)throw new Error("Unauthorized");
        const{data:profile,error:profileError}=await supabase.from("profiles").select("school_id").eq("id",user.id).single();if(profileError)throw profileError;
        const safe=photo.name.replace(/[^a-zA-Z0-9._-]/g,"-"),path=`${profile.school_id}/${id}/${crypto.randomUUID()}-${safe}`;
        const{error:uploadError}=await supabase.storage.from("item-photos").upload(path,photo,{contentType:photo.type,upsert:false});if(uploadError)throw uploadError;
        const{data:publicUrl}=supabase.storage.from("item-photos").getPublicUrl(path),{error:updateError}=await supabase.from("items").update({photo_url:publicUrl.publicUrl}).eq("id",id);if(updateError)throw updateError;
      }
    }
    return NextResponse.json({ok:true});
  }catch{return NextResponse.json({message:"Item or photo could not be saved."},{status:500});}
}
