FROM public.ecr.aws/lambda/ruby:2.7

COPY src/ ${LAMBDA_TASK_ROOT}

COPY Gemfile ${LAMBDA_TASK_ROOT}

ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle install
