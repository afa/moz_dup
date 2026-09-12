== что это

для Мозаичного форума в рамках починки и перехода на нормальный (не пэхапэ) код необходима миграция БД с мускула на постгрес. для миграции исторических данных и нужен этот модуль.

=== inconsistent data fixups

```sql
update forum_post set reportthreadid = 0 where reportthreadid in (select forum_post.reportthreadid from forum_post left outer join forum_thread on forum_thread.threadid = forum_post.reportthreadid where forum_post.reportthreadid != 0 and forum_thread.threadid is null);
update forum_post set threadid = 0 where threadid in (select forum_post.threadid from forum_post left outer join forum_thread on forum_thread.threadid = forum_post.threadid where forum_post.threadid != 0 and forum_thread.threadid is null);
update forum_post set parentid = 0 where parentid in (select distinct a.parentid from forum_post a left outer join forum_post b on a.parentid = b.postid where a.parentid != 0 and b.postid is null);
```

== что хотелось реализовать

== ToDo
