drop view if exists core.users_to_achievements;
create view core.users_to_achievements as
select
  user_id,
  achievement_id,
  created_at
from main.users_to_achievements;

alter view core.users_to_achievements owner to postgres;