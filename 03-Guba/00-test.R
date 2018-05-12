library(mongolite)
conn <- mongo(collection = 'guba', db = 'guba', url = "mongodb://localhost:27017")
iter <- conn$iterate(query = '{}', field = '{"_id":0, "post_id":1, "reply":1}')

# �������ȱʧֵ�ĺ�������iter��ȡ֮�󣬿�����ЩԪ����NULL������NULL������Ϊrbindlist�����룬������Ҫ�����ĳɿ�list
# ע�⣬NULL��NA��list() ������length����0���������ǲ�ͬ�Ķ���������漰�� R �ؼ��� object type����һ��ҪŪ������������Ĵ����㿴���������������
set_empty_to_na <- function(x, null.as)) {
    if (length(x) == 0) { 
        if (is.null(x)) {
            x <- null.as
        }
    } 
    x
}

# ����� ���� make_post_reply ������ batch �棬�������� batch �治�ȶ�������ֻ���� one()��
#make_post_reply <- function(batch) {
    #lapply(batch, `[[`, "reply") %>% lapply(set_empty_to_na, null.as = list()) %>% lapply(rbindlist, fill = T, use.names = T) %>% rbindlist(use.names = T, fill = T)
#}

make_post_reply <- function(one) {
    # ��one" ����һ�м�¼
    # reply �ǰ�one��reply������ȡ������data.table��
    reply <- one["reply"] %>% lapply(set_empty_to_na, null.as = list()) %>% lapply(rbindlist, fill = T, use.names = T) %>% rbindlist(use.names = T, fill = T)
    # post �ǰ� one ��post ������ȡ������һ��������
    # ������ post ֻ��ȡ�� post_id��������Լ��ģ���ȡ���������ֻ������ʱ��Ҫ��post���һ��data.table
    post <- one$post_id %>% sapply(set_empty_to_na, null.as = NA, USE.NAMES = F)

    # ���post_id �ǿգ�post_id��˵��ץȡ�����г��ִ���������ټ������� �������ɵ�post��reply �ϲ��ɳ�һ��data.table
    if (!is.null(post)) {
        if (nrow(reply) == 0) { # ��� reply �����ڣ���ô���ɵ�dt��ֻ��post
            data.table(post.id = post)
        } else { # ���reply ���ڣ���ô��replyҲ����dt
            data.table(post.id = post, reply)
        }
    } else {# ��� post_id �գ���ô�����dt��ע�����Ǹ��ؼ����������� �� data.table������� NULL �� NA���ͻᱨ�������漰�������Ķ���һ���ԣ��Ǹ��ѵ㡣
        data.table()
    }
}

# ���ж�ȡ
posts <- data.table()
while (!is.null(res <- iter$one())) {
    chunk <- make_post_reply(res)
    posts <- rbindlist(list(chunk, posts), use.names = T, fill = T)
}