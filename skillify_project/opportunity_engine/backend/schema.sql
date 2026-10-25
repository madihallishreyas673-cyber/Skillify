-- PostgreSQL schema for the NEXT stage (cloud accounts + sync + monetization).
-- Version 1 of the app stores everything on the phone; this is not connected yet.

create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  password_hash text not null,          -- argon2/bcrypt, never plain text
  name text not null,
  role text not null default 'seeker',  -- seeker | employer
  created_at timestamptz not null default now()
);

create table profiles (
  user_id uuid primary key references users(id) on delete cascade,
  data jsonb not null default '{}'      -- assessment answers, chosen career
);

create table progress (
  user_id uuid references users(id) on delete cascade,
  lesson_id text not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

create table applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  job_ref text not null,                -- id/url of the real listing
  status text not null default 'applied',
  updated_at timestamptz not null default now()
);

create table documents (               -- resumes/portfolios; files go to cloud storage
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  kind text not null,
  storage_key text not null,
  created_at timestamptz not null default now()
);

-- Monetization-ready (payments NOT implemented yet)
create table plans (
  id text primary key,                  -- free | premium | employer | recruiter
  name text not null,
  features jsonb not null default '{}'
);

create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  plan_id text references plans(id),
  status text not null default 'inactive',
  provider_ref text,
  renews_at timestamptz
);

create table employer_jobs (           -- verified employer postings (future)
  id uuid primary key default gen_random_uuid(),
  employer_id uuid references users(id),
  title text not null,
  details jsonb not null default '{}',
  verified boolean not null default false
);
