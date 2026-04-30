  create table "public"."workflow_test" (
    "id" uuid not null default gen_random_uuid(),
    "test_name" text not null,
    "created_at" timestamp with time zone default now()
      );
alter table "public"."workflow_test" enable row level security;
CREATE UNIQUE INDEX workflow_test_pkey ON public.workflow_test USING btree (id);
alter table "public"."workflow_test" add constraint "workflow_test_pkey" PRIMARY KEY using index "workflow_test_pkey";
