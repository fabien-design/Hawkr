-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.hawker_center_votes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  vote smallint NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  hawker_center_id uuid,
  CONSTRAINT hawker_center_votes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.hawker_centers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NOT NULL,
  longitude double precision NOT NULL,
  latitude double precision NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  image_url text,
  CONSTRAINT hawker_centers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.menu_item_votes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  menu_item_id uuid NOT NULL,
  vote smallint NOT NULL CHECK (vote = ANY (ARRAY[1, '-1'::integer])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT menu_item_votes_pkey PRIMARY KEY (id),
  CONSTRAINT miv_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT miv_menu_item_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id)
);
CREATE TABLE public.menu_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL,
  description text,
  stall_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  image_url text,
  CONSTRAINT menu_items_pkey PRIMARY KEY (id),
  CONSTRAINT menu_items_stall_id_fkey FOREIGN KEY (stall_id) REFERENCES public.street_foods(id)
);
CREATE TABLE public.menu_items_tags (
  menu_item_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  assigned_by uuid,
  CONSTRAINT menu_items_tags_pkey PRIMARY KEY (menu_item_id, tag_id),
  CONSTRAINT m_it_fk_menu_item FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id),
  CONSTRAINT m_it_fk_tag FOREIGN KEY (tag_id) REFERENCES public.predefined_tags(id)
);
CREATE TABLE public.predefined_tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT predefined_tags_pkey PRIMARY KEY (id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text,
  display_name text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.street_food_votes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  vote smallint NOT NULL CHECK (vote = ANY (ARRAY[1, '-1'::integer])),
  created_at timestamp with time zone DEFAULT now(),
  street_food_id uuid,
  CONSTRAINT street_food_votes_pkey PRIMARY KEY (id),
  CONSTRAINT sfv_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT sfv_street_food_fkey FOREIGN KEY (street_food_id) REFERENCES public.street_foods(id)
);
CREATE TABLE public.street_foods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  longitude double precision NOT NULL,
  latitude double precision NOT NULL,
  hawker_center_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  image_url text,
  CONSTRAINT street_foods_pkey PRIMARY KEY (id),
  CONSTRAINT street_foods_hawker_center_id_fkey FOREIGN KEY (hawker_center_id) REFERENCES public.hawker_centers(id)
);
CREATE TABLE public.user_favorite_hawker_centers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  hawker_center_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_favorite_hawker_centers_pkey PRIMARY KEY (id),
  CONSTRAINT ufhc_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT ufhc_hawker_center_fkey FOREIGN KEY (hawker_center_id) REFERENCES public.hawker_centers(id)
);
CREATE TABLE public.user_favorite_menu_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  menu_item_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_favorite_menu_items_pkey PRIMARY KEY (id),
  CONSTRAINT ufmi_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT ufmi_menu_item_fkey FOREIGN KEY (menu_item_id) REFERENCES public.menu_items(id)
);
CREATE TABLE public.user_favorite_street_foods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  street_food_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_favorite_street_foods_pkey PRIMARY KEY (id),
  CONSTRAINT ufsf_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT ufsf_street_food_fkey FOREIGN KEY (street_food_id) REFERENCES public.street_foods(id)
);

