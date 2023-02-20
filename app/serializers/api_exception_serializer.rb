class ApiExceptionSerializer < ActiveModel::Serializer
  attributes :status, :code, :message
end