import uuid as py_uuid
from project import db
from sqlalchemy.dialects.postgresql import JSONB, UUID, ENUM
from sqlalchemy import (Column, Boolean, Integer, String, Date, DateTime,
  Numeric, Text, func)
import enum


MONITOR_TYPES = (
  'query_credit_quota',
  'runaway_query',
  'query_performance',
  'warehouse_credit_quota',
  'clustering_credit_quota',
  'materialized_view_credit_quota',
  'snowpipe_credit_quota'
)

class Monitor(db.Model):
  __tablename__ = "monitors"

  id = Column(UUID(as_uuid=True), default=py_uuid.uuid4, primary_key=True)
  name = Column(String)
  owner = Column(String)
  comment = Column(String, nullable=True)
  start_time = Column(DateTime)
  frequency = Column(Integer)
  credits_quota = Column(Integer)
  mon_type = Column(ENUM(*MONITOR_TYPES, name='monitor_type_enum'))
  credits_used = Column(Integer)
  created_at = Column(DateTime(timezone=True), default=func.now())
  updated_at = Column(DateTime(timezone=True), default=func.now(), onupdate=func.statement_timestamp())
  notify_threshold = Column(Integer)
  alarm_threshold = Column(Integer)


