# For Publishers created within the past 2 weeks, enqueue jobs to verify
# each unique brave_publisher_id.
class EnqueuePublisherVerifications < ActiveJob::Base
  queue_as :scheduler

  def perform
    n = 0
    brave_publisher_ids.each do |brave_publisher_id|
      VerifyPublisher.perform_later(brave_publisher_id: brave_publisher_id)
      n += 1
    end
    Rails.logger.info("EnqueuePublisherVerifications enqueued VerifyPublisher #{n} times.")
  end

  private

  # Get distinct unverified brave_publisher_ids created recently.
  def brave_publisher_ids
    Publisher
      .select(:brave_publisher_id).distinct
      .where.not(brave_publisher_id: Publisher.select(:brave_publisher_id).distinct.where(verified: true))
      .pluck(:brave_publisher_id)
  end
end
