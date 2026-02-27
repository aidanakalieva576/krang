INSERT INTO categories (id, name) VALUES
  (1,'Action'),
  (2,'Comedy'),
  (3,'Drama'),
  (4,'Horror'),
  (5,'Sci-Fi'),
  (6,'Romance'),
  (7,'Thriller'),
  (8,'Fantasy'),
  (9,'Adventure'),
  (10,'Animation'),
  (11,'Documentary'),
  (12,'Crime'),
  (13,'Mystery'),
  (14,'War'),
  (15,'Western'),
  (16,'Biography'),
  (17,'Music'),
  (18,'Sport'),
  (19,'Family'),
  (20,'History')
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (id, username, email, password_hash, avatar_url, role, is_active) VALUES
  (1,'admin','admin@mail.com','$2a$10$demo.admin.hash',NULL,'ADMIN',TRUE),
  (2,'demo','demo@mail.com','$2a$10$demo.user.hash',NULL,'USER',TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO movies (
  id,title,description,release_year,type,category_id,
  duration_seconds,thumbnail_url,video_url,is_hidden,trailer_url,
  created_by,platform,director
) VALUES
  (1,'Demo Movie: Neon Run','Action movie for demo mode.',2023,'MOVIE',1,5400,'https://example.com/thumbs/neon-run.jpg','https://example.com/videos/neon-run.mp4',FALSE,'https://example.com/trailers/neon-run.mp4',1,'KRANG Cinema','A. Director'),
  (2,'Demo Movie: Midnight Letters','Drama demo movie.',2022,'MOVIE',6,6120,'https://example.com/thumbs/midnight-letters.jpg','https://example.com/videos/midnight-letters.mp4',FALSE,'https://example.com/trailers/midnight-letters.mp4',1,'KRANG Cinema','B. Director'),
  (3,'Demo Series: Station 9','Firefighter demo series.',2024,'SERIES',3,NULL,'https://example.com/thumbs/station-9.jpg',NULL,FALSE,'https://example.com/trailers/station-9.mp4',1,'KRANG Cinema','C. Director')
ON CONFLICT (id) DO NOTHING;

INSERT INTO episodes (
  id,movie_id,title,description,
  episode_number,season_number,duration_seconds,
  video_url,release_date
) VALUES
  (1,3,'Pilot','First call.',1,1,2700,'https://example.com/videos/station-9-s1e1.mp4','2024-01-10'),
  (2,3,'After the Siren','Aftermath.',2,1,2760,'https://example.com/videos/station-9-s1e2.mp4','2024-01-17'),
  (3,3,'Rooftop','Rescue.',3,1,2820,'https://example.com/videos/station-9-s1e3.mp4','2024-01-24')
ON CONFLICT (id) DO NOTHING;

INSERT INTO collections (id,user_id,name,description) VALUES
  (1,2,'Favorites','My favorites'),
  (2,2,'Watch later','Later')
ON CONFLICT (id) DO NOTHING;

INSERT INTO collection_items (id,collection_id,movie_id) VALUES
  (1,1,1),
  (2,1,3),
  (3,2,2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO watch_progress (id,user_id,movie_id,episode_id,current_time_sec) VALUES
  (1,2,1,NULL,840),
  (2,2,3,2,1200)
ON CONFLICT (id) DO NOTHING;

INSERT INTO watch_logs (id,user_id,movie_id,episode_id,watch_time_sec,event_type) VALUES
  (1,2,1,NULL,600,'PLAY'),
  (2,2,1,NULL,240,'PAUSE'),
  (3,2,3,1,900,'PLAY'),
  (4,2,3,1,900,'COMPLETE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO support_messages (id,user_id,subject,message,reply,status) VALUES
  (1,2,'Video buffering','Video pauses.','Try lower quality.','ANSWERED'),
  (2,2,'Account','How change username?',NULL,'OPEN')
ON CONFLICT (id) DO NOTHING;

INSERT INTO movie_ratings (id,user_id,movie_id,rating,review) VALUES
  (1,2,1,8,'Good demo'),
  (2,2,2,9,'Nice drama')
ON CONFLICT (id) DO NOTHING;

INSERT INTO content_audit (id,actor_id,target_type,target_id,action,detail) VALUES
  (1,1,'MOVIE',1,'CREATE','{"title":"Demo Movie: Neon Run"}'::jsonb),
  (2,1,'MOVIE',3,'CREATE','{"title":"Demo Series: Station 9"}'::jsonb),
  (3,1,'EPISODE',1,'CREATE','{"movie_id":3}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO offline_downloads (id,user_id,movie_id,episode_id,file_path,file_size_bytes,expires_at) VALUES
  (1,2,1,NULL,'/offline/neon-run.mp4',1500000000,now()+interval '7 days'),
  (2,2,NULL,2,'/offline/station-9-s1e2.mp4',900000000,now()+interval '7 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO statistics_aggregates (id,period_start,period_type,total_views,avg_watch_sec,top_category_id,top_movie_id) VALUES
  (1,current_date,'DAY',12,1100,1,1),
  (2,date_trunc('month',current_date)::date,'MONTH',220,1400,6,2)
ON CONFLICT (id) DO NOTHING;


SELECT setval('categories_id_seq',(SELECT COALESCE(MAX(id),1) FROM categories));
SELECT setval('users_id_seq',(SELECT COALESCE(MAX(id),1) FROM users));
SELECT setval('movies_id_seq',(SELECT COALESCE(MAX(id),1) FROM movies));
SELECT setval('episodes_id_seq',(SELECT COALESCE(MAX(id),1) FROM episodes));
SELECT setval('collections_id_seq',(SELECT COALESCE(MAX(id),1) FROM collections));
SELECT setval('collection_items_id_seq',(SELECT COALESCE(MAX(id),1) FROM collection_items));
SELECT setval('watch_progress_id_seq',(SELECT COALESCE(MAX(id),1) FROM watch_progress));
SELECT setval('watch_logs_id_seq',(SELECT COALESCE(MAX(id),1) FROM watch_logs));
SELECT setval('support_messages_id_seq',(SELECT COALESCE(MAX(id),1) FROM support_messages));
SELECT setval('movie_ratings_id_seq',(SELECT COALESCE(MAX(id),1) FROM movie_ratings));
SELECT setval('content_audit_id_seq',(SELECT COALESCE(MAX(id),1) FROM content_audit));
SELECT setval('offline_downloads_id_seq',(SELECT COALESCE(MAX(id),1) FROM offline_downloads));
SELECT setval('statistics_aggregates_id_seq',(SELECT COALESCE(MAX(id),1) FROM statistics_aggregates));