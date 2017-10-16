library(RODBC)

# �ȵ���������Ҫ�õ������ݿ� ----
# r ��ʾδ���κ��޸�
# û��ǰ׺��ʾ�м����ݼ�
# ���� info �࣬ÿֻ����ֻռ һ�� ����
pp <- odbcConnect("SMPP")

# fund_infomation
r.pp.info <- sqlQuery(pp, "select * from [dbo].[fund_info]") %>% setDT() # ����״̬��
pp.info <- r.pp.info[, .(pp.fund.id = fund_id, pp.fund.code = fund_code, pp.fund.name = fund_name, pp.fund.name.short = fund_short_name, pp.fund.type = fund_type, pp.currency = base_currency, pp.foundation.date = inception_date, pp.performance.start.date = performance_inception_date, pp.lockup.period = lockup_period, pp.duration = duration, pp.initial.size = initial_size)] %>% unique(by = "pp.fund.id")