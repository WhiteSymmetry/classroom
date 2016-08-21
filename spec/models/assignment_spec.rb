# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Assignment, type: :model do
  it_behaves_like 'a default scope where deleted_at is not present'

  describe 'slug uniqueness' do
    let(:classroom) { create(:classroom) }

    it 'verifes that the slug is unique even if the titles are unique' do
      create(:assignment, classroom: classroom, title: 'assignment-1')
      new_assignment = build(:assignment, classroom: classroom, title: 'assignment 1')

      expect { new_assignment.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'uniqueness of title across classroom' do
    let(:classroom) { create(:classroom)    }
    let(:creator)   { classroom.users.first }

    let(:grouping) { Grouping.create(title: 'Grouping', classroom: classroom) }

    let(:group_assignment) do
      GroupAssignment.create(creator: creator,
                             title: 'Ruby Project',
                             classroom: classroom,
                             grouping: grouping)
    end

    let(:assignment) { Assignment.new(creator: creator, title: group_assignment.title, classroom: classroom) }

    it 'validates that a GroupAssignment in the same classroom does not have the same title' do
      validation_message = 'Validation failed: Your assignment title must be unique'
      expect { assignment.save! }.to raise_error(ActiveRecord::RecordInvalid, validation_message)
    end
  end

  describe 'uniqueness of title across application' do
    let(:classroom_1) { create(:classroom) }
    let(:classroom_2) { create(:classroom) }

    it 'allows two classrooms to have the same Assignment title and slug' do
      assignment_1 = create(:assignment, classroom: classroom_1)
      assignment_2 = create(:assignment, classroom: classroom_2, title: assignment_1.title)

      expect(assignment_2.title).to eql(assignment_1.title)
      expect(assignment_2.slug).to eql(assignment_1.slug)
    end
  end

  context 'with assignment' do
    subject { create(:assignment) }

    describe 'when the title is updated' do
      it 'updates the slug' do
        subject.update_attributes(title: 'New Title')
        expect(subject.slug).to eql('new-title')
      end
    end

    describe '#flipper_id' do
      it 'should return an id' do
        expect(subject.flipper_id).to eq("Assignment:#{subject.id}")
      end
    end

    describe '#public?' do
      it 'returns true if Assignments public_repo column is true' do
        expect(subject.public?).to be(true)
      end
    end

    describe '#private?' do
      it 'returns false if Assignments public_repo column is true' do
        expect(subject.private?).to be(false)
      end
    end
  end
end
