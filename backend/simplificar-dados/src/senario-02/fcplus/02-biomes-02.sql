-- criar campos de classificacao
alter table "bazil_luccme_cr_fcplus"
    drop column if exists "biome_id";
alter table "bazil_luccme_cr_fcplus"
    drop column if exists "biome_nm";
alter table "bazil_luccme_cr_fcplus"
    drop column if exists "biome_intersection_percentage";

alter table "bazil_luccme_cr_fcplus"
    add column "biome_id" INTEGER;
alter table "bazil_luccme_cr_fcplus"
    add column "biome_nm" VARCHAR;
alter table "bazil_luccme_cr_fcplus"
    add column "biome_intersection_percentage" NUMERIC;


-- popular atributos internos
update "bazil_luccme_cr_fcplus"
set "biome_id"                      = s_intersets.b_id,
    "biome_nm"                      = s_intersets.b_nm,
    "biome_intersection_percentage" = s_intersets.b_intersection_percentage
from (select s.id,
             b.id b_id,
             b.nm b_nm,
             1    b_intersection_percentage
      from "bazil_luccme_cr_fcplus" s,
           "biomes" b
      where st_intersects(s.geom, b.geom)
        and st_within(s.geom, b.geom)) s_intersets
where "bazil_luccme_cr_fcplus".id = s_intersets.id
  and "bazil_luccme_cr_fcplus"."biome_id" is null;


-- popular atributos de borda
update "bazil_luccme_cr_fcplus"
set "biome_id"                      = s_intersets.b_id,
    "biome_nm"                      = s_intersets.b_nm,
    "biome_intersection_percentage" = s_intersets.b_intersection_percentage
from (select s.id,
             b.id                                                       b_id,
             b.nm                                                       b_nm,
             st_area(st_intersection(s.geom, b.geom)) / st_area(s.geom) b_intersection_percentage
      from "bazil_luccme_cr_fcplus" s,
           "biomes" b
      where st_intersects(s.geom, b.geom)
        and not st_within(s.geom, b.geom)) s_intersets
where "bazil_luccme_cr_fcplus".id = s_intersets.id
  and "bazil_luccme_cr_fcplus"."biome_id" is null
  and s_intersets.b_intersection_percentage > 0.7;


-- ajustar atributos de borda
update "bazil_luccme_cr_fcplus"
set "biome_id"                      = s_intersets.b_id,
    "biome_nm"                      = s_intersets.b_nm,
    "biome_intersection_percentage" = s_intersets.b_intersection_percentage
from (select s.id,
             b.id                                                       b_id,
             b.nm                                                       b_nm,
             st_area(st_intersection(s.geom, b.geom)) / st_area(s.geom) b_intersection_percentage
      from "bazil_luccme_cr_fcplus" s,
           "biomes" b
      where st_intersects(s.geom, b.geom)) s_intersets
where "bazil_luccme_cr_fcplus".id = s_intersets.id
  and "bazil_luccme_cr_fcplus"."biome_id" is null;

create index "bazil_luccme_cr_fcplus_biome_id_idx" on "bazil_luccme_cr_fcplus" ("biome_id");